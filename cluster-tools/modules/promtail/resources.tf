resource "helm_release" "promtail" {

  depends_on = [
    helm_release.loki
  ]

  name = "promtail"

  namespace        = "monitoring"
  create_namespace = true

  repository = "https://grafana.github.io/helm-charts"
  chart      = "promtail"
  version    = "6.16.0" # Corresponds to Promtail 3.0.0

  timeout       = 1200
  wait          = true
  wait_for_jobs = true

  values = [
    file("${path.module}/values.yaml")
  ]
}
