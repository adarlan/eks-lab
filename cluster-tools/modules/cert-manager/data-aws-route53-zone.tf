data "aws_route53_zone" "zone" {
  name = "${var.registered_domain}."
}
