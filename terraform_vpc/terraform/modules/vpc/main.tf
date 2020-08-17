# Declare the data source
data "aws_availability_zones" "available" {
  state = "available"
}
locals {
  az_length = data.aws_availability_zones.available.names
}
# Internet VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc-cidr
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "${terraform.workspace}-${var.name}"
  }
}

# Subnets
resource "aws_subnet" "public-subnets" {
  count = length(var.public-subnet)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public-subnet[count.index]
  map_public_ip_on_launch = "true"
  availability_zone       = count.index+1 <= length(local.az_length) ? local.az_length[count.index+1] : null

  tags = {
    Name = "${terraform.workspace}-${var.name}-public-subnet-${count.index}"
  }
}


resource "aws_subnet" "private-subnets" {
  count = length(var.private-subnet)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private-subnet[count.index]
  map_public_ip_on_launch = "false"
  availability_zone       = count.index+1 <= length(local.az_length) ? local.az_length[count.index+1] : null

  tags = {
    Name = "${terraform.workspace}-${var.name}-private-subnet-${count.index}"
  }
}

# Internet GW
resource "aws_internet_gateway" "vpc-gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${terraform.workspace}-${var.name}-gw"
  }
}

# public route tables
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc-gw.id
  }

  tags = {
    Name = "${terraform.workspace}-${var.name}-public-route-table"
  }
}
# VPC setup for NAT
# nat gw
resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     =  aws_subnet.public-subnets[0].id
  depends_on    = [aws_internet_gateway.vpc-gw]
  tags = {
    Name = "${terraform.workspace}-${var.name}-nat-gw"
}
}
# private route table

resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }

  tags = {
    Name = "${terraform.workspace}-${var.name}-private-route-table"
  }
}
# route associations public
resource "aws_route_table_association" "public-subnets" {
  count = length(var.public-subnet)
  subnet_id      =  aws_subnet.public-subnets[count.index].id
  route_table_id = aws_route_table.public-route-table.id
}
