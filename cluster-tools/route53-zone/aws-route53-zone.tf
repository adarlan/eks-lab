resource "aws_route53_zone" "zone" {
  name = var.domain_name

  delegation_set_id = aws_route53_delegation_set.delegation_set.id
}
