resource "aws_security_group" "main" {
  vpc_id             = var.vpc_id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "TCP"
    cidr_blocks      = var.bastion_nodes
  }

  ingress {
    from_port        = var.app_port
    to_port          = var.app_port
    protocol         = "TCP"
    cidr_blocks      = var.server_app_port_sg_cidr
  }

  ingress {
    from_port        = 9100
    to_port          = 9100
    protocol         = "TCP"
    cidr_blocks      = var.prometheus_nodes
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-sg"
  }
}

resource "aws_instance" "instance" {
  ami                     = data.aws_ami.ami.image_id
  instance_type           = var.instance_type
  vpc_security_group_ids  = [aws_security_group.main.id]
  subnet_id               = var.subnets[0]
  root_block_device {
    encrypted             = true
    kms_key_id            = var.kms_key_id
  }

  tags = {
    Name    = var.component
    monitor = "yes"
    env     = var.env
  }
  lifecycle {
    ignore_changes = [
      ami,
    ]
  }
}

resource "null_resource" "ansible" {
  triggers = {
    instance = aws_instance.instance.id
    always_run = timestamp()
  }
  provisioner "remote-exec" {

    connection {
      type     = "ssh"
      user     = jsondecode(data.vault_generic_secret.ssh.data_json).ansible_user
      password = jsondecode(data.vault_generic_secret.ssh.data_json).ansible_password
      host     = aws_instance.instance.private_ip
    }


    inline = [
      "sudo pip3.11 install ansible hvac",
      "ansible-pull -i localhost, -U https://github.com/Devops-Stage-1/expense-ansible get-secrets.yml -e vault_token=${var.vault_token} -e component=${var.component} -e env=${var.env}",
      "ansible-pull -i localhost, -U https://github.com/Devops-Stage-1/expense-ansible expense.yml -e @~/secrets.json -e role_name=${var.component} -e env=${var.env} ",
      "rm -f ~/*.json"
    ]
    }
}

resource "aws_route53_record" "server-record" {
  count   = var.lb_needed ? 0 : 1
  zone_id = var.zone_id
  name    = "${var.component}-${var.env}"
  type    = "A"
  ttl     = 30
  records = [aws_instance.instance.private_ip]
}

resource "aws_route53_record" "lb-record" {
  count   = var.lb_needed ? 1 : 0
  zone_id = var.zone_id
  name    = "${var.component}-${var.env}"
  type    = "CNAME"
  ttl     = 30
  records = [aws_lb.main[0].dns_name]
}

resource "aws_security_group" "load_balancer" {
  count       = var.lb_needed ? 1 : 0
  name        = "${var.component}-${var.env}-alb-sg"
  description = "${var.component}-${var.env}-alb-sg"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.lb_port
    content {
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "TCP"
      cidr_blocks      = var.lb_app_port_sg_cidr
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.component}-${var.env}-alb-sg"
  }
}

resource "aws_lb" "main" {
  count               = var.lb_needed ? 1 : 0
  name                = "${var.component}-${var.env}-alb"
  internal            = var.lb_type =="public" ? false : true
  load_balancer_type  = "application"
  security_groups     = [aws_security_group.load_balancer[0].id]
  subnets             = var.lb_subnets

  tags = {
    Environment = "${var.component}-${var.env}-alb"
  }
}

resource "aws_lb_target_group" "main" {
  count                = var.lb_needed ? 1 : 0
  name                 = "${var.component}-${var.env}-alb-tg"
  port                 = var.app_port
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = 15

  health_check {
    healthy_threshold   = 2
    interval            = 5
    path                = "/health"
    port                = var.app_port
    timeout             = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "main" {
  count             = var.lb_needed ? 1 : 0
  target_group_arn  = aws_lb_target_group.main[0].arn
  target_id         = aws_instance.instance.id
  port              = var.app_port
}

resource "aws_lb_listener" "frontend-http" {
  count             = var.lb_needed && var.lb_type=="public"? 1 : 0
  load_balancer_arn = aws_lb.main[0].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "frontend-https" {
  count             = var.lb_needed && var.lb_type == "public" ? 1 : 0
  load_balancer_arn = aws_lb.main[0].arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[0].arn
  }
}

resource "aws_lb_listener" "load_balancer" {
  count             = var.lb_needed && var.lb_type !="public" ? 1 : 0
  load_balancer_arn = aws_lb.main[0].arn
  port              = var.app_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[0].arn
  }
}