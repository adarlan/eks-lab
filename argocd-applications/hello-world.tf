resource "kubernetes_manifest" "hello_world" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "hello-world"
      namespace = "argocd"
    }
    spec = {
      project = "default"
      destination = {
        name      = "in-cluster"
        namespace = "default"
      }
      syncPolicy = {
        automated = {
          selfHeal = true
          prune    = true
        }
      }
      source = {
        repoURL        = var.repository_ssh_clone_url
        targetRevision = "main"
        path           = "helm-charts/hello-world"
        helm = {
          releaseName = "hello-world"
          valuesObject = {
            message = "Cheguei, Brasil!"
            ingress = {
              host = var.application_host
            }
          }
        }
      }
    }
  }
}
