resource "tfe_project" "project" {
  organization = var.organization
  name         = var.project
}
