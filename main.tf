module "frontend" {
  source = "./modules/app"
  env = var.env
  instance_type = var.instance_type
  component = "frontend"
  ssh_user = var.ssh_user
  ssh_pass = var.ssh_pass
  zone_id = var.zone_id
}