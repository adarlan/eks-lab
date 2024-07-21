resource "aws_eip" "nat_eip" {

  for_each = local.nat_gateways

  domain = "vpc"

  tags = {
    Name = each.value.nat_eip_name
  }
}
