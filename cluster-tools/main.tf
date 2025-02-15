module "route53_zone" {
  source   = "./route53-zone"
  for_each = var.create_route53_zone ? { "${var.domain_name}" = {} } : {}

  domain_name = var.domain_name
}

module "ingress_nginx" {
  source     = "./ingress-nginx"
  depends_on = [module.route53_zone]
}

module "dns_records" {
  source     = "./dns-records"
  depends_on = [module.route53_zone, module.ingress_nginx]

  registered_domain = var.domain_name

  record_names = [
    "example",
    "grafana",
    "prometheus",
    # "*.example"
  ]

  load_balancer_name = module.ingress_nginx.load_balancer_name
}

module "oidc_provider" {
  source = "./oidc-provider"

  cluster_name = var.cluster_name
}

module "cert_manager" {
  source = "./cert-manager"

  registered_domain = var.domain_name
  oidc_provider_arn = module.oidc_provider.oidc_provider_arn
  oidc_provider_url = module.oidc_provider.oidc_provider_url
}

module "letsencrypt_issuers" {
  source     = "./letsencrypt-issuers"
  depends_on = [module.cert_manager]

  acme_email        = var.acme_email
  registered_domain = var.domain_name
}


# module "acm_certificate" {
#   source     = "./acm-certificate"
#   depends_on = [module.route53_zone]

#   domain_name = var.domain_name
#   subdomains = [
#     for host in var.ingress_hosts : substr(host, 0, length(host) - (length(var.domain_name) + 1)) if host != var.domain_name
#   ]
# }

# module "ingress_nginx" {
#   source     = "./ingress-nginx-aws-certificate-manager"
#   depends_on = [module.route53_zone, module.acm_certificate]

#   domain_name = var.domain_name
#   hosts       = var.ingress_hosts

#   eks_cluster_name    = var.cluster_name
#   acm_certificate_arn = module.acm_certificate.acm_certificate_arn
# }

# module "ingress_dns" {
#   source = "./elb-dns-record"
#   depends_on = [ module.ingress_nginx ]
#   registered_domain = var.registered_domain
#   subdomains = [
#     "*${var.base_subdomain}"
#   ]
# }

# module "argocd" {
#   source     = "./argocd"
#   depends_on = [module.ingress_nginx]

#   argocd_ingress_host = "argocd.${var.domain_name}"
# }

# module "loki" {
#   source = "./loki-simple-scalable"

#   aws_s3_bucket_name         = var.loki_s3_bucket_name
#   aws_iam_user_name          = "${var.cluster_name}-loki"
#   # loki_singlebinary_replicas = 2
#   is_prod                    = false
# }

# module "kube_prometheus_stack" {
#   source     = "./kube-prometheus-stack"
#   depends_on = [module.ingress_nginx]

#   grafana_ingress_host    = "grafana.${var.domain_name}"
#   prometheus_ingress_host = "prometheus.${var.domain_name}"
# }
