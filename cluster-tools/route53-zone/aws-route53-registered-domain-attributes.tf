# Note: This resource behaves differently from normal resources.
# Terraform does not register the domain, but instead "adopts" it into management.
# Terraform won't create or delete the domain registration.
# This resource is used only to set attributes in the registered domain.

resource "aws_route53domains_registered_domain" "registered_domain" {

  domain_name = var.domain_name

  dynamic "name_server" {
    for_each = aws_route53_delegation_set.delegation_set.name_servers
    content {
      name = name_server.value
    }
  }
}
