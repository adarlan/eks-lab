resource "aws_nat_gateway" "nat_gateway" {

  for_each = local.nat_gateways

  allocation_id = aws_eip.nat_eip[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = {

    Name = each.value.nat_gateway_name

    # NOTE To ensure proper ordering, it is recommended to add an explicit dependency on the VPC's Internet Gateway.
    # As the Internet Gateway is not defined in this module, the dependency is implicit by this tag.
    internet_gateway_id = var.internet_gateway_id
  }
}
