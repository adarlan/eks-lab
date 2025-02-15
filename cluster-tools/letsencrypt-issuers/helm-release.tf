resource "helm_release" "letsencrypt_issuer" {

  name = "letsencrypt-issuer"

  #   namespace = ""
  #   create_namespace = true
  # TODO define namespace?
  # will helm create its management secret into the default namespace?

  chart = "${path.module}/helm-chart"

  timeout       = 240
  wait          = true
  wait_for_jobs = true

  dynamic "set" {
    for_each = local.helm_values
    content {
      name  = set.key
      value = set.value
    }
  }
}

locals {
  helm_values = {
    "acme_email"      = var.acme_email
    "route53_region"  = data.aws_region.current_region.name
    "route53_zone_id" = data.aws_route53_zone.zone.id
  }
}
