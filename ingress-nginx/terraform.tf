terraform {
  required_version = "1.10.5"

  cloud {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.86.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.35.1"
    }
  }
}
