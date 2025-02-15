data "kubernetes_service" "ingress_nginx_controller" {
  depends_on = [helm_release.ingress_nginx]

  metadata {
    # TODO what if the namespace or the helm release name change?
    name      = "ingress-nginx-controller"
    namespace = "ingress"
  }
}
