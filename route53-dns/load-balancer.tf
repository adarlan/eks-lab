locals {
  load_balancer_name = ""
  # TODO use tfe provider to get ingress-nginx load_balancer_name output
  # or check if kubernetes add tags to the load balancer
}

data "aws_lb" "ingress_nginx_load_balancer" {
  name = local.load_balancer_name
}

locals {
  load_balancer_dns_name = data.aws_lb.ingress_nginx_load_balancer.dns_name
  load_balancer_zone_id  = data.aws_lb.ingress_nginx_load_balancer.zone_id
}
