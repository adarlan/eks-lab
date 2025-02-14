locals {
  cluster_name = var.cluster_name

  cluster_security_group_name = "${local.cluster_name}-security-group"
  cluster_role_name           = "${local.cluster_name}-role"
  cluster_oidc_provider_name  = "${local.cluster_name}-oidc-provider"
}
