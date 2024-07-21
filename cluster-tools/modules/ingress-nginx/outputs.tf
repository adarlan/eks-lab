output "load_balancer_name" {
  value = split("-", data.kubernetes_service.ingress_nginx_controller.status[0].load_balancer[0].ingress[0].hostname)[0]
}
