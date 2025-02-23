locals {
  argocd_release_name = "argo-cd"
  argocd_namespace    = "argocd"
}

resource "helm_release" "argo_cd" {
  # depends_on = [kubernetes_namespace.namespace]

  name      = local.argocd_release_name
  namespace = local.argocd_namespace

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "6.4.1"

  timeout       = 300
  wait          = true
  wait_for_jobs = true

  values = [yamlencode({

    # argo-cd helm values reference:
    # https://github.com/argoproj/argo-helm/blob/main/charts/argo-cd/values.yaml

    configs = {
      params = {
        "server.insecure" = true
      }
      cm = {
        "timeout.reconciliation" = "30s"
      }
    }

    crds = {
      keep = true
      # TODO disable
    }

    global = {
      domain = var.argocd_host
    }

    server = {
      ingress = {
        enabled          = true
        ingressClassName = var.ingress_class_name
        annotations = {
          "cert-manager.io/cluster-issuer" = var.cluster_issuer_name
        }
        extraTls = [
          {
            secretName = "${var.argocd_host}-tls"
            hosts      = [var.argocd_host]
          }
        ]
      }
    }

  })]
}

data "kubernetes_secret" "argocd_initial_admin_secret" {
  depends_on = [helm_release.argo_cd]

  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = local.argocd_namespace
  }
}

locals {
  argocd_admin_user     = "admin"
  argocd_admin_password = data.kubernetes_secret.argocd_initial_admin_secret.data["password"]
}

output "argocd_admin_credentials" {
  value = {
    user     = local.argocd_admin_user
    password = local.argocd_admin_password
  }
  sensitive = true
}
