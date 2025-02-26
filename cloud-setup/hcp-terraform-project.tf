resource "tfe_project" "project" {
  organization = var.hcp_terraform_organization
  name         = var.github_repository
}
