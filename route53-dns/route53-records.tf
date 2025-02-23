# -----------------------------------------------------------------------------
# DNS records
# -----------------------------------------------------------------------------
# 
# Create Route53 records for each host pointing to the ingress-nginx load
# balancer.
# 
# -----------------------------------------------------------------------------

resource "aws_route53_record" "dns_record" {
  for_each = {
    for host in toset(var.hosts) : host => {
      record_name = (host == var.domain) ? "" : substr(host, 0, length(host) - length(".${var.domain}"))
    }
  }

  zone_id = local.route53_zone_id
  name    = each.value.record_name
  type    = "A"

  alias {
    name    = local.load_balancer_dns_name
    zone_id = local.load_balancer_zone_id

    evaluate_target_health = true
  }
}
