data "tls_certificate" "cluster_tls_certificate" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster_tls_certificate.certificates[0].sha1_fingerprint]
  url             = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

locals {
  oidc_provider_arn = aws_iam_openid_connect_provider.oidc_provider.arn
  oidc_provider_url = aws_iam_openid_connect_provider.oidc_provider.url
}
