data "aws_region" "region" {}

data "aws_availability_zones" "available_zones" {
  state = "available"
}

locals {

  vpc_name              = "${var.cluster_name}-vpc"
  internet_gateway_name = "${var.cluster_name}-internet-gateway"

  eligible_zone_names = [
    for x in var.eligible_zones : format("%s%s", data.aws_region.region.name, x)
  ]

  available_zone_names = data.aws_availability_zones.available_zones.names

  eligible_zones_available = length(local.eligible_zone_names) == 0 ? local.available_zone_names : setintersection(
    local.eligible_zone_names,
    local.available_zone_names
  )

  selected_zones = (
    (var.max_selected_zones > 0) && (length(local.eligible_zones_available) > var.max_selected_zones)
  ) ? slice(local.eligible_zones_available, 0, var.max_selected_zones) : local.eligible_zones_available

  nat_gateway_count = min(var.max_nat_gateway_count, length(local.selected_zones))

  nat_gateway_zones = slice(local.selected_zones, 0, local.nat_gateway_count)

  public_route_table_name = "${var.cluster_name}-internet-gateway-route-table"

  public_subnets = {
    for index, az_name in local.selected_zones : az_name => {
      availability_zone = az_name
      subnet_name       = "${var.cluster_name}-public-subnet-${az_name}"
      cidr_block        = cidrsubnet(var.vpc_cidr_block, var.subnet_cidr_block_newbits, index)
    }
  }

  private_subnets = {
    for index, az_name in local.selected_zones : az_name => {
      availability_zone = az_name
      subnet_name       = "${var.cluster_name}-private-subnet-${az_name}"
      cidr_block        = cidrsubnet(var.vpc_cidr_block, var.subnet_cidr_block_newbits, length(local.selected_zones) + index)
    }
  }

  nat_gateways = {
    for index, az_name in local.nat_gateway_zones : az_name => {
      nat_gateway_name         = "${var.cluster_name}-nat-gateway-${az_name}"
      nat_eip_name             = "${var.cluster_name}-nat-gateway-eip-${az_name}"
      private_route_table_name = "${var.cluster_name}-nat-gateway-route-table-${az_name}"
    }
  }

  private_route_table_associations = local.nat_gateway_count > 0 ? {
    for index, az_name in local.selected_zones : az_name => {
      nat_gateway_zone = local.selected_zones[index % local.nat_gateway_count]
    }
  } : {}
}

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

    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "kubernetes.io/role/internal-elb"           = "1"
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

    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "kubernetes.io/role/internal-elb"           = "1"
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
