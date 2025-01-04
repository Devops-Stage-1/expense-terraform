env = "dev"
instance_type = "t3.small"
zone_id = "Z03550633TO0Y0IZ4C5ZP"


#vpc
vpc_cidr_block = "10.10.0.0/24"
default_vpc_cidr_block = "172.31.0.0/16"
default_vpc_id = "vpc-0c0512145af7b05ce"
default_route_table_id = "rtb-0b55b2a100efd10c3"


frontend_subnets    = ["10.10.0.0/27", "10.10.0.32/27"]
backend_subnets     = ["10.10.0.64/27", "10.10.0.96/27"]
db_subnets          = ["10.10.0.128/27", "10.10.0.160/27"]
public_subnets      = ["10.10.0.192/27", "10.10.0.224/27"]
availability_zones  = ["us-east-1a", "us-east-1b"]
bastion_nodes       = ["172.31.43.224/32"]
prometheus_nodes    = ["172.31.90.44/32"]
kms_key_id          = "arn:aws:kms:us-east-1:235494793390:key/d91bbef7-3841-40c1-b9a2-f7f5e92ef92a"
certificate_arn     = "arn:aws:acm:us-east-1:235494793390:certificate/52ca4c0e-164c-4bbc-9276-82149fdf2e72"

#ASG
min_size = 1
max_size = 5
desired_capacity = 1
