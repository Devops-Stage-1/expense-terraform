module "frontend" {
  depends_on              = [module.backend]

  source                  = "./modules/app"
  env                     = var.env
  instance_type           = var.instance_type
  component               = "frontend"
  zone_id                 = var.zone_id
  vault_token             = var.vault_token
  vpc_id                  = module.vpc.vpc_id
  subnets                 = module.vpc.frontend_subnets
  lb_needed               = true
  lb_type                 = "public"
  lb_subnets              = module.vpc.public_subnets
  app_port                = 80
  bastion_nodes           = var.bastion_nodes
  server_app_port_sg_cidr = var.public_subnets
  prometheus_nodes        = var.prometheus_nodes
  lb_app_port_sg_cidr     = ["0.0.0.0/0"]
  certificate_arn         = "arn:aws:acm:us-east-1:235494793390:certificate/52ca4c0e-164c-4bbc-9276-82149fdf2e72"
  lb_port                 = {http: 80, https: 443}
}

module "backend" {
  depends_on    = [module.mysql]

  source        = "./modules/app"
  env           = var.env
  instance_type = var.instance_type
  component     = "backend"
  zone_id       = var.zone_id
  vault_token   = var.vault_token
  vpc_id        = module.vpc.vpc_id
  subnets       = module.vpc.backend_subnets
  lb_needed     = true
  lb_type       = "private"
  lb_subnets    = module.vpc.backend_subnets
  app_port      = 8080
  bastion_nodes = var.bastion_nodes
  server_app_port_sg_cidr = var.backend_subnets
  # server_app_port_sg_cidr = concat(var.frontend_subnets, var.backend_subnets)
  prometheus_nodes        = var.prometheus_nodes
  lb_app_port_sg_cidr     = var.frontend_subnets
  lb_port                 = {http: 8080}
}

module "mysql" {
  source                  = "./modules/app"

  env                     = var.env
  instance_type           = var.instance_type
  component               = "mysql"
  zone_id                 = var.zone_id
  vault_token             = var.vault_token
  vpc_id                  = module.vpc.vpc_id
  subnets                 = module.vpc.db_subnets
  app_port                = 3306
  bastion_nodes           = var.bastion_nodes
  server_app_port_sg_cidr = var.backend_subnets
  prometheus_nodes        = var.prometheus_nodes
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