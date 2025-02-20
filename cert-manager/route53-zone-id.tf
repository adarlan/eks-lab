data "aws_route53_zone" "zone" {
  name = "${var.domain}."
}

locals {
  route53_zone_id = data.aws_route53_zone.zone.id
}
