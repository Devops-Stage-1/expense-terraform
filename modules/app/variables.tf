variable "instance_type" {}
variable "component" {}
variable "zone_id" {}
variable "env" {}
variable "vault_token" {}
variable "vpc_id" {}
variable "subnets" {}
variable "lb_needed" {
  default = false
}
variable "lb_type" {
  default = null
}
variable "lb_subnets" {
  default = null
}
variable "app_port" {}
variable "bastion_nodes" {}
variable "server_app_port_sg_cidr" {}
variable "prometheus_nodes" {}
variable "lb_app_port_sg_cidr" {
  default = null
}
# variable "lb_app_port_sg_cidr" {
#   default = []
# }