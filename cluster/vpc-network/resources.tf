# -----------------------------------------------
# VPC
# -----------------------------------------------

resource "aws_vpc" "vpc" {

  cidr_block = var.vpc_cidr_block

  enable_dns_support   = true
  enable_dns_hostnames = true
  # https://docs.aws.amazon.com/vpc/latest/userguide/vpc-dns.html#vpc-dns-support
  # enable_dns_support and enable_dns_hostnames must be enabled for EFS (?)

  tags = {
    Name = local.vpc_name
  }
}

# -----------------------------------------------
# Internet gateway
# -----------------------------------------------

resource "aws_internet_gateway" "internet_gateway" {

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = local.internet_gateway_name
  }
}

# -----------------------------------------------
# Private subnets
# -----------------------------------------------

resource "aws_subnet" "private" {

  for_each = local.private_subnets

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = false

  tags = {
    "Name" = each.value.subnet_name

    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
    "kubernetes.io/role/internal-elb"               = "1"
  }
}

# -----------------------------------------------
# Public subnets
# -----------------------------------------------

resource "aws_subnet" "public" {

  for_each = local.public_subnets

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true

  tags = {
    "Name" = each.value.subnet_name

    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
    "kubernetes.io/role/internal-elb"               = "1"
  }
}

# -----------------------------------------------
# Elastic IPs for NAT gateways
# -----------------------------------------------

resource "aws_eip" "nat_eip" {

  for_each = local.nat_gateways

  domain = "vpc"

  tags = {
    Name = each.value.nat_eip_name
  }
}

# -----------------------------------------------
# NAT gateways
# -----------------------------------------------

resource "aws_nat_gateway" "nat_gateway" {

  for_each = local.nat_gateways

  depends_on = [
    # To ensure proper ordering, it is recommended to add an explicit
    # dependency on the internet gateway.
    aws_internet_gateway.internet_gateway
  ]

  allocation_id = aws_eip.nat_eip[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = {
    Name = each.value.nat_gateway_name
  }
}

# -----------------------------------------------
# Public route table
# -----------------------------------------------

resource "aws_route_table" "public" {

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = local.public_route_table_name
  }
}

resource "aws_route_table_association" "public" {
  for_each = local.public_subnets

  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

# -----------------------------------------------
# Private route tables
# -----------------------------------------------

resource "aws_route_table" "private" {

  for_each = local.nat_gateways

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway[each.key].id
  }

  tags = {
    Name = each.value.private_route_table_name
  }
}

resource "aws_route_table_association" "private" {

  for_each = local.private_route_table_associations

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.value.nat_gateway_zone].id
}
