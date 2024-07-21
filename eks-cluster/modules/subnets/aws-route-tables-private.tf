resource "aws_route_table" "private" {

  for_each = local.nat_gateways

  vpc_id = var.vpc_id

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
