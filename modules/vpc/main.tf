resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags    = {
    Name  = "${var.env}-vpc"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_cidr_block

  tags    = {
    Name  = "${var.env}-subnet"
  }
}

resource "aws_vpc_peering_connection" "main" {
  peer_vpc_id   = aws_vpc.main.id
  vpc_id        = var.default_vpc_id
  auto_accept   = true
  tags    = {
    Name  = "${var.env}-peer"
  }

}

resource "aws_route" "vpc" {
  route_table_id            = aws_vpc.main.default_route_table_id
  destination_cidr_block    = var.default_vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}

resource "aws_route" "default_vpc" {
  route_table_id            = var.default_route_table_id
  destination_cidr_block    = var.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}
