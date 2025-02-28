terraform {
  required_version = "1.10.5"

  backend "local" {}

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
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.6"
    }
  }
}
