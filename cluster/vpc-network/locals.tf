locals {

  vpc_name              = "${var.eks_cluster_name}-vpc"
  internet_gateway_name = "${var.eks_cluster_name}-internet-gateway"

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

  public_route_table_name = "${var.eks_cluster_name}-internet-gateway-route-table"

  public_subnets = {
    for index, az_name in local.selected_zones : az_name => {
      availability_zone = az_name
      subnet_name       = "${var.eks_cluster_name}-public-subnet-${az_name}"
      cidr_block        = cidrsubnet(var.vpc_cidr_block, var.subnet_cidr_block_newbits, index)
    }
  }

  private_subnets = {
    for index, az_name in local.selected_zones : az_name => {
      availability_zone = az_name
      subnet_name       = "${var.eks_cluster_name}-private-subnet-${az_name}"
      cidr_block        = cidrsubnet(var.vpc_cidr_block, var.subnet_cidr_block_newbits, length(local.selected_zones) + index)
    }
  }

  nat_gateways = {
    for index, az_name in local.nat_gateway_zones : az_name => {
      nat_gateway_name         = "${var.eks_cluster_name}-nat-gateway-${az_name}"
      nat_eip_name             = "${var.eks_cluster_name}-nat-gateway-eip-${az_name}"
      private_route_table_name = "${var.eks_cluster_name}-nat-gateway-route-table-${az_name}"
    }
  }

  private_route_table_associations = local.nat_gateway_count > 0 ? {
    for index, az_name in local.selected_zones : az_name => {
      nat_gateway_zone = local.selected_zones[index % local.nat_gateway_count]
    }
  } : {}
}
