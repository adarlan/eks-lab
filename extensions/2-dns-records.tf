data "aws_route53_zone" "registered_domain_zone" {
  name = "${var.registered_domain}."
}

data "aws_lb" "ingress_nginx_load_balancer" {
  name = local.ingress_nginx_load_balancer_name
}

resource "aws_route53_record" "dns_record" {

  for_each = {
    for record_name in var.record_names : "${record_name}${record_name == "" ? "" : "."}${var.registered_domain}" => {
      record_name = record_name
    }
  }

  zone_id = data.aws_route53_zone.registered_domain_zone.id
  name    = each.value.record_name
  type    = "A"

  alias {
    name    = data.aws_lb.ingress_nginx_load_balancer.dns_name
    zone_id = data.aws_lb.ingress_nginx_load_balancer.zone_id

    evaluate_target_health = true
  }
}
