data "kubernetes_secret" "kube_prometheus_stack_grafana" {
  depends_on = [helm_release.kube_prometheus_stack]

  metadata {
    name      = "${local.release_name}-grafana"
    namespace = local.namespace
  }
}

output "grafana_admin_credentials" {
  value = {
    user     = data.kubernetes_secret.kube_prometheus_stack_grafana.data["admin-user"]
    password = data.kubernetes_secret.kube_prometheus_stack_grafana.data["admin-password"]
  }
  sensitive = true
}
