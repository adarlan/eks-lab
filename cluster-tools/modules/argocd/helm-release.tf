resource "helm_release" "argo_cd" {

  name = "argo-cd"

  namespace        = "argocd"
  create_namespace = true

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "7.1.5"

  timeout       = 300
  wait          = true
  wait_for_jobs = true

  values = [
    file("${path.module}/${local.helm_values_file}")
  ]

  dynamic "set" {
    for_each = local.helm_values
    content {
      name  = set.key
      value = set.value
    }
  }
}
