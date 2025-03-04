data "tfe_organization" "current" {}

data "tfe_workspace" "current" {
  name         = terraform.workspace
  organization = data.tfe_organization.current.name
}
