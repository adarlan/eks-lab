terraform {
  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "5.42.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.12.1"
    }
  }
}
