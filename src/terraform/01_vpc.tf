provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      application = "kylejsherman"
    }
  }
}

locals {
  vpc_tags = {
    service = "VPC"
  }
}

###########################################################################
# Create VPC, internet gateway
###########################################################################
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = merge(
    local.vpc_tags,
    {
      Name = "website_vpc"
    }
  )
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    local.vpc_tags,
    {
      Name = "website_igw"
    }
  )
}

###########################################################################
# Create public subnets, associated route table, and security group
###########################################################################
resource "aws_subnet" "public_1" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = merge(
    local.vpc_tags,
    {
      Name = "website_public_subnet_1"
    }
  )
}

resource "aws_subnet" "public_2" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  tags = merge(
    local.vpc_tags,
    {
      Name = "website_public_subnet_2"
    }
  )
}

resource "aws_route_table" "public_routes" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    local.vpc_tags,
    {
      Name = "website_public_route_table"
    }
  )
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_1_subnet_public_route" {
  subnet_id = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_routes.id
}

resource "aws_route_table_association" "public_2_subnet_public_route" {
  subnet_id = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_routes.id
}

resource "aws_security_group" "public_subnet_sg" {
  name = "website_public_sg"
  description = "A sg for the public subnets with web servers"
  vpc_id = aws_vpc.vpc.id
  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "allow incoming ssh traffic"
    from_port = 22
    protocol = "tcp"
    to_port = 22
  }
  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "allow incoming http traffic"
    from_port = 80
    protocol = "tcp"
    to_port = 80
  }
  egress {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "allow all outgoing traffic"
    from_port = 0
    protocol = "-1"
    to_port = 0
  }
}

###########################################################################
# Create private subnets, associated route table, security group, nat gateway, and elastic ip
###########################################################################
resource "aws_subnet" "private_1" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.3.0/24"
  tags = merge(
    local.vpc_tags,
    {
      Name = "website_private_subnet_1"
    }
  )
}

resource "aws_subnet" "private_2" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.4.0/24"
  tags = merge(
    local.vpc_tags,
    {
      Name = "website_private_subnet_2"
    }
  )
}

resource "aws_eip" "nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "public_nat_gateway" {
  allocation_id = aws_eip.nat_eip.allocation_id
  subnet_id = aws_subnet.public_1.id
  tags = merge(
    local.vpc_tags,
    {
      Name = "website_nat_gateway"
    }
  )
}

resource "aws_route_table" "private_routes" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    local.vpc_tags,
    {
      Name = "website_private_route_table"
    }
  )
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.public_nat_gateway.id
  }
}

resource "aws_route_table_association" "private_1_subnet_public_route" {
  subnet_id = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_routes.id
}

resource "aws_route_table_association" "private_2_subnet_public_route" {
  subnet_id = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_routes.id
}

resource "aws_security_group" "private_subnet_sg" {
  name = "website_private_sg"
  description = "A sg for the private subnets for backend"
  vpc_id = aws_vpc.vpc.id
  ingress {
    description = "allow incoming ssh traffic"
    from_port = 22
    protocol = "tcp"
    security_groups = [aws_security_group.public_subnet_sg.id]
    to_port = 22
  }
  egress {
    description = "allow all outgoing traffic"
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    protocol = "-1"
    to_port = 0
  }
}