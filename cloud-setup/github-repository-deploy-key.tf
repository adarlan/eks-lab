# This creates an SSH key on the GitHub repository that will be used by Argo CD to fetch applications deployment config.

resource "tls_private_key" "repository_deploy_key" {
  algorithm = "ED25519"
}

resource "github_repository_deploy_key" "repository_deploy_key" {
  repository = var.github_repository
  title      = "${local.base_name}-repository-deploy-key"
  key        = tls_private_key.repository_deploy_key.public_key_openssh
  read_only  = true
}

# GitHub says:
# We recommend using GitHub Apps instead for fine grained control over repositories and enhanced security.
# https://docs.github.com/apps/creating-github-apps/about-creating-github-apps/about-creating-github-apps
# https://docs.github.com/apps/creating-github-apps/about-creating-github-apps/deciding-when-to-build-a-github-app#github-apps-offer-enhanced-security
