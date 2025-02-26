provider "tfe" {}

provider "github" {}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      project = var.github_repository
    }
  }
}
