terraform {
  required_version = "1.10.5"

  cloud {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.86.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.35.1"
    }
  }
}
