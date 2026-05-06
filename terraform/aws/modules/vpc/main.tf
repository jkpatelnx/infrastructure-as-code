#################################################
# Availability Zones
#################################################

data "aws_availability_zones" "available_az" {}


#################################################
# VPC 
#################################################

resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = var.vpc_name
  }
}

#################################################
# VPC Internet Gateway.
#################################################

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = var.internet_gateway_name
  }
}

#################################################
# Public Subnets
#################################################

resource "aws_subnet" "my_public_subnet_1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.public_subnet_1_cidr_block
  availability_zone       = data.aws_availability_zones.available_az.names[var.public_subnet_1_az_index]
  map_public_ip_on_launch = true
  tags = {
    Name = var.public_subnet_1_name
  }
}

resource "aws_subnet" "my_public_subnet_2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.public_subnet_2_cidr_block
  availability_zone       = data.aws_availability_zones.available_az.names[var.public_subnet_2_az_index]
  map_public_ip_on_launch = true
  tags = {
    Name = var.public_subnet_2_name
  }
}

#################################################
# Private Subnets
#################################################

resource "aws_subnet" "my_private_subnet_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnet_1_cidr_block
  availability_zone = data.aws_availability_zones.available_az.names[var.private_subnet_1_az_index]
  tags = {
    Name = var.private_subnet_1_name
  }
}

resource "aws_subnet" "my_private_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnet_2_cidr_block
  availability_zone = data.aws_availability_zones.available_az.names[var.private_subnet_2_az_index]
  tags = {
    Name = var.private_subnet_2_name
  }
}

#################################################
# Public Network ACL
#################################################

resource "aws_network_acl" "public_nacl" {
  vpc_id = aws_vpc.my_vpc.id

  subnet_ids = [
    aws_subnet.my_public_subnet_1.id,
    aws_subnet.my_public_subnet_2.id
  ]

  ingress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "public_nacl"
  }
}

#################################################
# Private Network ACL
#################################################

resource "aws_network_acl" "private_nacl" {
  vpc_id = aws_vpc.my_vpc.id

  subnet_ids = [
    aws_subnet.my_private_subnet_1.id,
    aws_subnet.my_private_subnet_2.id
  ]

  ingress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "private_nacl"
  }
}


#################################################
# Elastic IPs  -->  NAT Gateway
#################################################


resource "aws_eip" "nat_eip_1" {
  domain = "vpc"
  tags = {
    Name = var.nat_eip_1_name
  }
}

resource "aws_eip" "nat_eip_2" {
  domain = "vpc"
  tags = {
    Name = var.nat_eip_2_name
  }
}

#################################################
# NAT Gateway.
#################################################

resource "aws_nat_gateway" "my_nat_1" {
  allocation_id = aws_eip.nat_eip_1.id
  subnet_id     = aws_subnet.my_public_subnet_1.id
  tags = {
    Name = var.nat_gateway_1_name
  }
  depends_on = [aws_internet_gateway.my_igw]
}

resource "aws_nat_gateway" "my_nat_2" {
  allocation_id = aws_eip.nat_eip_2.id
  subnet_id     = aws_subnet.my_public_subnet_2.id
  tags = {
    Name = var.nat_gateway_2_name
  }
  depends_on = [aws_internet_gateway.my_igw]
}

#################################################
# Shared Public Route Table
#################################################

resource "aws_route_table" "my_shared_public_route_table1" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = var.public_route_table_name
  }
}



#################################################
# Private Route Tables
#################################################

resource "aws_route_table" "my_private_route_table1" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my_nat_1.id
  }

  tags = {
    Name = var.private_route_table_1_name
  }
}

resource "aws_route_table" "my_private_route_table2" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my_nat_2.id
  }

  tags = {
    Name = var.private_route_table_2_name
  }
}

#################################################
# Route Table Associations
#################################################

resource "aws_route_table_association" "my_shared_public_route_table1" {
  subnet_id      = aws_subnet.my_public_subnet_1.id
  route_table_id = aws_route_table.my_shared_public_route_table1.id
}
resource "aws_route_table_association" "my_shared_public_route_table2" {
  subnet_id      = aws_subnet.my_public_subnet_2.id
  route_table_id = aws_route_table.my_shared_public_route_table1.id
}

resource "aws_route_table_association" "my_private_route_table1" {
  subnet_id      = aws_subnet.my_private_subnet_1.id
  route_table_id = aws_route_table.my_private_route_table1.id
}

resource "aws_route_table_association" "my_private_route_table2" {
  subnet_id      = aws_subnet.my_private_subnet_2.id
  route_table_id = aws_route_table.my_private_route_table2.id
}
