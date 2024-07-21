locals {

  nat_gateway_count = min(var.max_nat_gateway_count, length(var.availability_zones))

  nat_gateway_zones = slice(var.availability_zones, 0, local.nat_gateway_count)

  public_route_table_name = "${var.eks_cluster_name}-internet-gateway-route-table"

  public_subnets = {
    for index, az_name in var.availability_zones : az_name => {
      availability_zone = az_name
      subnet_name       = "${var.eks_cluster_name}-${az_name}-public-subnet"
      cidr_block        = cidrsubnet(var.vpc_cidr_block, var.subnet_cidr_block_newbits, index)
    }
  }

  private_subnets = {
    for index, az_name in var.availability_zones : az_name => {
      availability_zone = az_name
      subnet_name       = "${var.eks_cluster_name}-${az_name}-private-subnet"
      cidr_block        = cidrsubnet(var.vpc_cidr_block, var.subnet_cidr_block_newbits, length(var.availability_zones) + index)
    }
  }

  nat_gateways = {
    for index, az_name in local.nat_gateway_zones : az_name => {
      nat_gateway_name         = "${var.eks_cluster_name}-${az_name}-nat-gateway"
      nat_eip_name             = "${var.eks_cluster_name}-${az_name}-nat-gateway-elastic-ip"
      private_route_table_name = "${var.eks_cluster_name}-${az_name}-nat-gateway-route-table"
    }
  }

  private_route_table_associations = local.nat_gateway_count > 0 ? {
    for index, az_name in var.availability_zones : az_name => {
      nat_gateway_zone = var.availability_zones[index % local.nat_gateway_count]
    }
  } : {}
}
