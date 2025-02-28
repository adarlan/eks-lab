resource "kubernetes_secret" "repository_deploy_key" {

  metadata {
    name      = "${var.github_repository}-repository-deploy-key"
    namespace = local.argocd_namespace
    labels = {
      "argocd.argoproj.io/secret-type" : "repository"
    }
  }

  type = "Opaque"

  data = {
    url           = var.repository_ssh_clone_url
    sshPrivateKey = base64decode(var.repository_deploy_key)
  }
}
