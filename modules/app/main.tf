resource "aws_instance" "instance" {
  ami                     = data.aws_ami.ami.image_id
  instance_type           = var.instance_type
  vpc_security_group_ids  = [data.aws_security_group.selected.id]

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
      host     = aws_instance.instance.public_ip
    }


    inline = [
      "sudo pip3.11 install ansible",
      "ansible-pull -i localhost, -U https://github.com/Devops-Stage-1/expense-ansible get-secrets.yml -e vault_token=${var.vault_token}",
      "ansible-pull -i localhost, -U https://github.com/Devops-Stage-1/expense-ansible expense.yml -e secrets.json -e role_name=${var.component} ",
      "rm -f secrets.json"
    ]
    }
}

resource "aws_route53_record" "record" {
  zone_id = var.zone_id
  name    = "${var.component}-${var.env}"
  type    = "A"
  ttl     = 30
  records = [aws_instance.instance.private_ip]
}
