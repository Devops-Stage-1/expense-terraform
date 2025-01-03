resource "aws_db_instance" "main" {
  db_name                 = "mydb"
  engine                  = var.engine
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  username                = jsondecode(data.vault_generic_secret.ssh.data_json).rds_username
  password                = jsondecode(data.vault_generic_secret.ssh.data_json).rds_password
  parameter_group_name    = aws_db_parameter_group.main.name
  skip_final_snapshot     = true
  identifier              = "rds-dev"
  multi_az                = false
  allocated_storage       = var.allocated_storage
  storage_type            = var.storage_type
  vpc_security_group_ids  = [aws]
  db_subnet_group_name    = aws_db_subnet_group.main.name
  publicly_accessible     = false
  storage_encrypted       = true
  kms_key_id              = var.kms_key_id
}

resource "aws_db_subnet_group" "main" {
  name       = "main"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.component}-${var.env}-subnet"
  }
}

resource "aws_db_parameter_group" "main" {
  name   = "rds-pg"
  family = var.family

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}

resource "aws_security_group" "main" {
  vpc_id             = var.vpc_id


  ingress {
    from_port        = 3306
    to_port          = 3306
    protocol         = "TCP"
    cidr_blocks      = var.server_app_port_sg_cidr
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}