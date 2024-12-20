# module "frontend" {
#   depends_on = [module.backend]
#
#   source = "./modules/app"
#   env = var.env
#   instance_type = var.instance_type
#   component = "frontend"
#   zone_id = var.zone_id
#   vault_token = var.vault_token
# }
#
# module "backend" {
#   depends_on = [module.mysql]
#
#   source = "./modules/app"
#   env = var.env
#   instance_type = var.instance_type
#   component = "backend"
#   zone_id = var.zone_id
#   vault_token = var.vault_token
# }
#
# module "mysql" {
#   source = "./modules/app"
#   env = var.env
#   instance_type = var.instance_type
#   component = "mysql"
#   zone_id = var.zone_id
#   vault_token = var.vault_token
# }

module "vpc" {
  source  = "./modules/vpc"
  vpc_cidr_block = var.vpc_cidr_block
  subnet_cidr_block = var.subnet_cidr_block
  env     = var.env
  default_vpc_id= var.default_vpc_id
  default_vpc_cidr_block = var.default_vpc_cidr_block
  default_route_table_id = var.default_route_table_id

}