resource "helm_release" "kube_prometheus_stack" {

  name = "kube-prometheus-stack"

  namespace        = "monitoring"
  create_namespace = true

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "56.6.2" # TODO the latest is 60.1.0

  timeout       = 1200 # Creation complete after 3m17s; Modifications complete after 5m32s
  wait          = true
  wait_for_jobs = true

  values = [
    file("${path.module}/helm-values.yaml")
  ]

  set {
    name  = "grafana.ingress.enabled"
    value = true
  }

  set {
    name  = "grafana.ingress.hosts[0]"
    value = var.grafana_ingress_host
  }

  set {
    name  = "prometheus.ingress.enabled"
    value = true
  }

  set {
    name  = "prometheus.ingress.hosts[0]"
    value = var.prometheus_ingress_host
  }
}
