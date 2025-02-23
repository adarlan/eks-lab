locals {
  release_name       = "ingress-nginx"
  namespace          = "ingress"
  ingress_class_name = "default-ingress-class"
}

resource "helm_release" "ingress_nginx" {
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.10.1"

  name      = local.release_name
  namespace = local.namespace

  wait          = true
  wait_for_jobs = true

  # ingress-nginx Helm values reference:
  # https://github.com/kubernetes/ingress-nginx/blob/main/charts/ingress-nginx/values.yaml
  values = [yamlencode({

    controller = {

      service = {
        annotations = {

          # Kubernetes AWS Load Balancer Controller annotations reference:
          # https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/guide/service/annotations/

          # Create a Network Load Balancer (NLB) instead of a Classic Load
          # Balancer (ELB). By default, it creates an ELB. NLB is best suited
          # for ultra-high-performance applications and those requiring extreme
          # reliability, handling TCP, UDP, and TLS traffic at the transport
          # layer (Layer 4).
          "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
        }
      }

      # Required for ACME to pass the HTTP-01 challenge.
      # By default, the ingress-nginx-controller doesn't watch ingresses without the ingress-class annotation.
      # Since cert-manager will create ingresses with deprecated annotations to pass the HTTP-01 challenge, we need to enable this option.
      # TODO Check if it's still the case for recent versions of cert-manager.
      watchIngressWithoutClass = true

      ingressClassResource = {
        name = local.ingress_class_name
      }

      extraArgs = {

        # Command line arguments reference:
        # https://github.com/kubernetes/ingress-nginx/blob/main/docs/user-guide/cli-arguments.md

        ingress-class = local.ingress_class_name
      }
    }
  })]
}

locals {
  ingress_nginx_controller_service_name = local.release_name == "ingress-nginx" ? "ingress-nginx-controller" : "${local.release_name}-ingress-nginx-controller"
}

data "kubernetes_service" "ingress_nginx_controller" {
  depends_on = [helm_release.ingress_nginx]

  metadata {
    name      = local.ingress_nginx_controller_service_name
    namespace = local.namespace
  }
}

locals {
  load_balancer_name = split("-", data.kubernetes_service.ingress_nginx_controller.status[0].load_balancer[0].ingress[0].hostname)[0]
}

data "aws_lb" "ingress_nginx_load_balancer" {
  name = local.load_balancer_name
}

locals {
  load_balancer_dns_name = data.aws_lb.ingress_nginx_load_balancer.dns_name
  load_balancer_zone_id  = data.aws_lb.ingress_nginx_load_balancer.zone_id
}
