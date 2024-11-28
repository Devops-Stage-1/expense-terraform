module "frontend" {
  source = "./modules/app"
  env = var.env
  instance_type = var.instance_type
  component = "frontend"
  ssh_user = var.ssh_user
  ssh_pass = var.ssh_pass
  zone_id = var.zone_id
}

module "backend" {
  depends_on = [module.mysql]

  source = "./modules/app"
  env = var.env
  instance_type = var.instance_type
  component = "backend"
  ssh_user = var.ssh_user
  ssh_pass = var.ssh_pass
  zone_id = var.zone_id
}

module "mysql" {
  source = "./modules/app"
  env = var.env
  instance_type = var.instance_type
  component = "mysql"
  ssh_user = var.ssh_user
  ssh_pass = var.ssh_pass
  zone_id = var.zone_id
}