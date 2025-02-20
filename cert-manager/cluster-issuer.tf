resource "kubernetes_manifest" "cluster_issuer" {
  depends_on = [helm_release.cert_manager]

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = var.cluster_issuer_name
    }
    spec = {
      acme = {
        server = local.acme_server
        email  = var.acme_email
        privateKeySecretRef = {
          name = var.cluster_issuer_name
        }
        solvers = [
          {
            dns01 = {
              route53 = {
                region       = local.aws_region
                hostedZoneID = local.route53_zone_id
              }
            }
          }
        ]
      }
    }
  }
}
