module "frontend"{
  depends_on = [module.backend]
  source                  = "./modules/app-asg"
  component               = "frontend"
  env                     = var.env
  instance_type           = var.instance_type
  max_size                = var.max_size
  desired_capacity        = var.desired_capacity
  min_size                = var.min_size
  subnet_ids              = module.vpc.frontend_subnets
  app_port                = 80
  server_app_port_sg_cidr = var.public_subnets
  vpc_id                  = module.vpc.vpc_id
  bastion_nodes           = var.bastion_nodes
  prometheus_nodes        = var.prometheus_nodes
  vault_token             = var.vault_token
  certificate_arn         = var.certificate_arn
  lb_app_port_sg_cidr     = ["0.0.0.0/0"]
  lb_port                 = {http: 80, https: 443}
  lb_subnets              = module.vpc.public_subnets
  lb_type                 = "public"
  zone_id                 = var.zone_id
}

module "backend"{
  depends_on = [module.rds]
  source                  = "./modules/app-asg"
  component               = "backend"
  env                     = var.env
  instance_type           = var.instance_type
  max_size                = var.max_size
  desired_capacity        = var.desired_capacity
  min_size                = var.min_size
  subnet_ids              = module.vpc.backend_subnets
  app_port                = 8080
  server_app_port_sg_cidr = var.backend_subnets
  vpc_id                  = module.vpc.vpc_id
  bastion_nodes           = var.bastion_nodes
  prometheus_nodes        = var.prometheus_nodes
  vault_token             = var.vault_token
  certificate_arn         = var.certificate_arn
  lb_app_port_sg_cidr     = var.frontend_subnets
  lb_port                 = { http : 8080 }
  lb_subnets              = module.vpc.backend_subnets
  lb_type                 = "private"
  zone_id                 = var.zone_id
}

module "rds" {
  depends_on = [module.vpc]
  source = "./modules/rds"
  allocated_storage       = 20
  component               = "rds"
  engine                  = "mysql"
  engine_version          = "8.4.3"
  env                     = var.env
  instance_class          = "db.t3.micro"
  kms_key_id              = var.kms_key_id
  family                  = "mysql8.4"
  storage_type            = "gp3"
  subnet_ids              = module.vpc.db_subnets
  server_app_port_sg_cidr = var.backend_subnets
  vpc_id                  = module.vpc.vpc_id
}

module "vpc" {
  source                  = "./modules/vpc"
  vpc_cidr_block          = var.vpc_cidr_block
  env                     = var.env
  default_vpc_id          = var.default_vpc_id
  default_vpc_cidr_block  = var.default_vpc_cidr_block
  default_route_table_id  = var.default_route_table_id
  frontend_subnets        = var.frontend_subnets
  availability_zones      = var.availability_zones
  backend_subnets         = var.backend_subnets
  db_subnets              = var.db_subnets
  public_subnets          = var.public_subnets
}

# module "frontend" {
#   depends_on              = [module.backend]
#
#   source                  = "./modules/app"
#   env                     = var.env
#   instance_type           = var.instance_type
#   component               = "frontend"
#   zone_id                 = var.zone_id
#   vault_token             = var.vault_token
#   vpc_id                  = module.vpc.vpc_id
#   subnets                 = module.vpc.frontend_subnets
#   lb_needed               = true
#   lb_type                 = "public"
#   lb_subnets              = module.vpc.public_subnets
#   app_port                = 80
#   bastion_nodes           = var.bastion_nodes
#   server_app_port_sg_cidr = var.public_subnets
#   prometheus_nodes        = var.prometheus_nodes
#   lb_app_port_sg_cidr     = ["0.0.0.0/0"]
#   certificate_arn         = var.certificate_arn
#   lb_port                 = {http: 80, https: 443}
#   kms_key_id              = var.kms_key_id
# }
#
# module "backend" {
#   depends_on    = [module.rds]
#
#   source        = "./modules/app"
#   env           = var.env
#   instance_type = var.instance_type
#   component     = "backend"
#   zone_id       = var.zone_id
#   vault_token   = var.vault_token
#   vpc_id        = module.vpc.vpc_id
#   subnets       = module.vpc.backend_subnets
#   lb_needed     = true
#   lb_type       = "private"
#   lb_subnets    = module.vpc.backend_subnets
#   app_port      = 8080
#   bastion_nodes = var.bastion_nodes
#   server_app_port_sg_cidr = var.backend_subnets
#   # server_app_port_sg_cidr = concat(var.frontend_subnets, var.backend_subnets)
#   prometheus_nodes        = var.prometheus_nodes
#   lb_app_port_sg_cidr     = var.frontend_subnets
#   lb_port                 = {http: 8080}
#   kms_key_id              = var.kms_key_id
# }

# module "mysql" {
#   source                  = "./modules/app"
#
#   env                     = var.env
#   instance_type           = var.instance_type
#   component               = "mysql"
#   zone_id                 = var.zone_id
#   vault_token             = var.vault_token
#   vpc_id                  = module.vpc.vpc_id
#   subnets                 = module.vpc.db_subnets
#   app_port                = 3306
#   bastion_nodes           = var.bastion_nodes
#   server_app_port_sg_cidr = var.backend_subnets
#   prometheus_nodes        = var.prometheus_nodes
# }