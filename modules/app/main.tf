resource "aws_security_group" "main" {
  vpc_id      = var.vpc_id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg"
  }
}

resource "aws_instance" "instance" {
  ami                     = data.aws_ami.ami.image_id
  instance_type           = var.instance_type
  vpc_security_group_ids  = [aws_security_group.main.id]
  subnet_id = var.subnets[0]
  tags = {
    Name = var.component
    monitor = "yes"
    env = var.env
  }
}

resource "null_resource" "ansible" {

  provisioner "remote-exec" {

    connection {
      type     = "ssh"
      user     = jsondecode(data.vault_generic_secret.ssh.data_json).ansible_user
      password = jsondecode(data.vault_generic_secret.ssh.data_json).ansible_password
      host     = aws_instance.instance.private_ip
    }


    inline = [
      "sudo pip3.11 install ansible hvac",
      "ansible-pull -i localhost, -U https://github.com/Devops-Stage-1/expense-ansible get-secrets.yml -e vault_token=${var.vault_token}",
      "ansible-pull -i localhost, -U https://github.com/Devops-Stage-1/expense-ansible expense.yml -e @~/secrets.json -e @~/newrelic.json -e role_name=${var.component} ",
      "rm -f ~/secrets.json ~/newrelic.json"
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

resource "aws_lb" "main" {
  count               = var.lb_needed ? 1 : 0
  name                = "${var.component}-${var.env}-alb"
  internal            = var.lb_type =="public" ? false : true
  load_balancer_type  = "application"
  security_groups     = [aws_security_group.main.id]
  subnets             = var.lb_subnets

  tags = {
    Environment = "${var.component}-${var.env}-alb"
  }
}

resource "aws_lb_target_group" "main" {
  count    = var.lb_needed ? 1 : 0
  name     = "${var.component}-${var.env}-alb-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group_attachment" "main" {
  count             = var.lb_needed ? 1 : 0
  target_group_arn  = aws_lb_target_group.main[0].arn
  target_id         = aws_instance.instance.id
  port              = var.app_port
}

resource "aws_lb_listener" "front_end" {
  count             = var.lb_needed ? 1 : 0
  load_balancer_arn = aws_lb.main[0].arn
  port              = var.app_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[0].arn
  }
}