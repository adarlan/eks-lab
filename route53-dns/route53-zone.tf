# -----------------------------------------------------------------------------
# Route53 zone
# -----------------------------------------------------------------------------

resource "aws_route53_delegation_set" "managed_delegation_set" {
  count = var.enable_route53_zone_management ? 1 : 0

  reference_name = var.domain
}

resource "aws_route53_zone" "managed_zone" {
  count = var.enable_route53_zone_management ? 1 : 0

  name              = var.domain
  delegation_set_id = aws_route53_delegation_set.managed_delegation_set[0].id
}

resource "aws_route53domains_registered_domain" "registered_domain" {
  count = var.enable_route53_zone_management ? 1 : 0

  # This resource behaves differently from normal resources. Terraform does not
  # register the domain, but instead "adopts" it into management. Terraform
  # won't create or delete the domain registration. This resource is used only
  # to set attributes in the registered domain.

  domain_name = var.domain

  dynamic "name_server" {
    for_each = aws_route53_delegation_set.managed_delegation_set[0].name_servers
    content {
      name = name_server.value
    }
  }
}

data "aws_route53_zone" "zone" {
  depends_on = [aws_route53_zone.managed_zone]

  name = "${var.domain}."
}

locals {
  route53_zone_id = data.aws_route53_zone.zone.id
}

# TODO add option to create the zone without updating the registered domain
# so that the engineers will copy the name servers and add to the domain
