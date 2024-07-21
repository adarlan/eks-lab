resource "helm_release" "ingress_nginx" {

  name      = "ingress-nginx"
  namespace = "ingress"

  create_namespace = true
  # TODO the namespaces should be previously created with resource quotas and limit ranges

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.10.1"

  timeout       = 240
  wait          = true
  wait_for_jobs = true

  values = [
    file("${path.module}/helm-values.yaml")
  ]
}
