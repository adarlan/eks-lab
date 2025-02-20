locals {
  release_name = "kube-prometheus-stack"
  namespace    = "monitoring"
}

# Helm chart reference:
# https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack
resource "helm_release" "kube_prometheus_stack" {

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "56.6.2"

  name      = local.release_name
  namespace = local.namespace

  create_namespace = true

  wait          = true
  wait_for_jobs = true

  # Helm values reference:
  # https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/values.yaml
  values = [yamlencode({

    crds = {
      enabled = false
    }

    # TODO enable alertmanager ingress?

    prometheus = {
      ingress = {
        enabled          = true
        ingressClassName = var.ingress_class_name
        hosts            = [var.prometheus_host]
        pathType         = "ImplementationSpecific"
        paths            = ["/(.*)"]

        annotations = merge(

          # ingress-nginx annotations reference:
          # https://github.com/kubernetes/ingress-nginx/blob/main/docs/user-guide/nginx-configuration/annotations.md
          {
            "nginx.ingress.kubernetes.io/use-regex"      = "true"
            "nginx.ingress.kubernetes.io/rewrite-target" = "/$1"
          },

          {
            "cert-manager.io/cluster-issuer" = var.cluster_issuer_name
          }
        )

        tls = [
          {
            secretName = "${var.prometheus_host}-tls"
            hosts      = [var.prometheus_host]
          }
        ]
      }
    }

    grafana = {
      ingress = {
        enabled          = true
        ingressClassName = var.ingress_class_name
        hosts            = [var.grafana_host]
        path             = "/"

        annotations = {
          "cert-manager.io/cluster-issuer" = var.cluster_issuer_name
        }

        tls = [
          {
            secretName = "${var.grafana_host}-tls"
            hosts      = [var.grafana_host]
          }
        ]
      }

      # TODO add loki data source
      # additionalDataSources:
      # - name: loki
      #   uid: loki
      #   editable: false
      #   orgId: 1
      #   type: loki
      #   url: http://loki-gateway:80
      #   version: 1
      #   jsonData:
      #     httpHeaderName1: 'X-Scope-OrgID'
      #   secureJsonData:
      #     httpHeaderValue1: '1'
    }

  })]
}
