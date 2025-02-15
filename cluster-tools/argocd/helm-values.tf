locals {

  # helm_values_file = "helm-values-ssl-passthrough.yaml"
  helm_values_file = "helm-values-ssl-termination-at-ingress-controller.yaml"
  # helm_values_file = "helm-values-ssl-termination-at-ingress-controller-wildcard-certificate.yaml"

  helm_values_override = {

    "helm-values-ssl-passthrough.yaml" = {
      "crds.keep"     = false
      "global.domain" = var.argocd_ingress_host
    }

    "helm-values-ssl-termination-at-ingress-controller.yaml" = {
      "crds.keep"                           = false
      "global.domain"                       = var.argocd_ingress_host
    }

    "helm-values-ssl-termination-at-ingress-controller-wildcard-certificate.yaml" = {
      "crds.keep"                           = false
      "global.domain"                       = var.argocd_ingress_host
      "server.ingress.extraTls[0].hosts[0]" = var.argocd_ingress_host
    }

    # "configs.cm.timeout\\.reconciliation" = "30s"
    # "server.ingress.extraTls[0].hosts[0]" = var.argocd_ingress_host
    # "server.ingress.extraTls[0].secretName" = "argocd-ingress-http"
    # "configs.cm.url" = "https://${var.argocd_ingress_host}"
  }

  helm_values = local.helm_values_override[local.helm_values_file]
}
