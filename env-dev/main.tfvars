env = "dev"
instance_type = "t3.small"
zone_id = "Z03550633TO0Y0IZ4C5ZP"


#vpc
vpc_cidr_block = "10.10.0.0/24"
default_vpc_cidr_block = "172.31.0.0/16"
default_vpc_id = "vpc-0c0512145af7b05ce"
default_route_table_id = "rtb-0b55b2a100efd10c3"


frontend_subnets   = ["10.10.0.0/27", "10.10.0.32/27"]
backend_subnets    = ["10.10.0.64/27", "10.10.0.96/27"]
db_subnets         = ["10.10.0.128/27", "10.10.0.160/27"]
public_subnets     = ["10.10.0.192/27", "10.10.0.224/27"]
availability_zones = ["us-east-1a", "us-east-1b"]