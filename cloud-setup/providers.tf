terraform {
  required_version = "1.10.5"

  backend "local" {}
  # This is the only Terraform configuration that uses local state.

  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "0.64.0"
    }
    github = {
      source  = "integrations/github"
      version = "6.5.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.87.0"
    }
  }
}

provider "tfe" {}

provider "github" {}

provider "aws" {
  region = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = var.aws_default_tags
  }
}
