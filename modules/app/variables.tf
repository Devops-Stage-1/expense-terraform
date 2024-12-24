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