# TODO what's the difference between clusterissuer and issuer?

resource "kubernetes_manifest" "letsencrypt_cluster_issuer" {
  depends_on = [helm_release.cert_manager]
  # TODO Even though it depends on cert-manager,
  # terraform plan fails because the clusterissuer CRD is not present.
  # Install CRDs in the cluster config?
  # - certificaterequests.cert-manager.io
  # - certificates.cert-manager.io
  # - challenges.acme.cert-manager.io
  # - clusterissuers.cert-manager.io
  # - issuers.cert-manager.io
  # - orders.acme.cert-manager.io
  # Creating a helm chart with this manifest could solve the problem.

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-dns01-staging"
      # TODO define namespace?
    }
    spec = {
      acme = {
        server = "https://acme-staging-v02.api.letsencrypt.org/directory"
        email  = var.acme_email
        privateKeySecretRef = {
          name = "letsencrypt-staging-dns01-key-pair"
        }
        solvers = [
          {
            dns01 = {
              route53 = {
                region       = var.aws_region
                hostedZoneID = data.aws_route53_zone.registered_domain_zone.id
              }
            }
          }
        ]
      }
    }
  }
}
