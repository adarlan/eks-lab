data "tls_certificate" "cluster_tls_certificate" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}
