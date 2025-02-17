locals {
  acme_server = var.acme_production ? "" : "https://acme-staging-v02.api.letsencrypt.org/directory"
  # TODO add production server url
}

resource "helm_release" "default_cluster_issuer" {
  depends_on = [helm_release.cert_manager]

  name  = "default-cluster-issuer"
  chart = "${path.module}/kubernetes-manifest"

  # Using the kubernetes-manifest Helm chart to create a ClusterIssuer because
  # if we create the ClusterIssuer using the kubernetes_manifest Terraform resource,
  # even though it depends on the Helm release responsible for creating the ClusterIssuer CRD,
  # Terraform plan fails because Kubernetes evaluates the manifest during the plan,
  # before cert-manager and its CRDs are installed.
  # Using a the helm_release Terraform resource,
  # Kubernetes only evaluates the manifest during the apply,
  # after cert-manager and its CRDs are already installed.

  values = [yamlencode({
    manifest = {
      apiVersion = "cert-manager.io/v1"
      kind       = "ClusterIssuer"
      metadata = {
        name = "default-cluster-issuer"
      }
      spec = {
        acme = {
          server = local.acme_server
          email  = var.acme_email
          privateKeySecretRef = {
            name = "default-cluster-issuer"
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
  })]
}
