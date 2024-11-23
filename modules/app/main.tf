resource "aws_instance" "instance" {
  ami                     = data.aws_ami.ami.image_id
  instance_type           = var.instance_type
  vpc_security_group_ids  = [data.aws_security_group.selected.id]

  tags = {
    Name = var.component
  }
}

resource "null_resource" "ansible" {
  connection {
    type     = "ssh"
    user     = var.ssh_user
    password = var.ssh_pass
    host     = aws_instance.instance.public_ip
}

  provisioner "remote-exec" {
    inline = [
      "sudo pip3.11 install ansible",
      "ansbile-playbook -i localhost, -U https://github.com/Devops-Stage-1/expense-ansible ${component}.yml"
      ]
    }
}

resource "aws_route53_record" "record" {
  zone_id = var.zone_id
  name    = "${component}-${env}-tf"
  type    = "A"
  ttl     = 30
  records = [aws_instance.instance.private_ip]
}
