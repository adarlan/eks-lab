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

  values = [yamlencode({
    # Ref: https://github.com/kubernetes/ingress-nginx/blob/main/charts/ingress-nginx/values.yaml

    # Ref: Command line arguments
    # https://github.com/kubernetes/ingress-nginx/blob/main/docs/user-guide/cli-arguments.md

    # Ref: Annotations - AWS Load Balancer Controller
    # https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/guide/service/annotations/

    controller = {

      service = {
        annotations = {

          # Create a Network Load Balancer (NLB) instead of a Classic Load Balancer (ELB).
          # By default, it creates an ELB.
          # NLB is best suited for ultra-high-performance applications and those requiring extreme reliability,
          # handling TCP, UDP, and TLS traffic at the transport layer (Layer 4).
          "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
        }
      }

      # Required for ACME to pass the HTTP-01 challenge.
      # By default, the ingress-nginx-controller doesn't watch ingresses without the new ingress-class annotation.
      # Since cert-manager will create ingresses with deprecated annotations to pass the HTTP-01 challenge, we need to enable this option.
      # TODO Check if it's still the case for recent versions of cert-manager.
      watchIngressWithoutClass = true

      # TODO Need this?
      # The tutorial uses 'external-nginx', but I changed to 'ingres', which is the default value
      # Can remove these configurations?
      ingressClassResource = {
        name = "nginx"
        # name: external-nginx
      }

      extraArgs = {
        ingress-class = "nginx"
        # ingress-class: external-nginx
      }
    }
  })]
}

data "kubernetes_service" "ingress_nginx_controller" {
  depends_on = [helm_release.ingress_nginx]

  metadata {
    # TODO what if the namespace or the helm release name change?
    name      = "ingress-nginx-controller"
    namespace = "ingress"
  }
}

locals {
  ingress_nginx_load_balancer_name = split("-", data.kubernetes_service.ingress_nginx_controller.status[0].load_balancer[0].ingress[0].hostname)[0]
}
