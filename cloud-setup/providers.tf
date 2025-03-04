provider "tfe" {
  organization = var.hcp_terraform_organization
}

provider "github" {}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      project = var.github_repository
    }
  }
}
