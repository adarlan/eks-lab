terraform {

  cloud {
    organization = "adarlan-teixeira"

    workspaces {
      name = "my-eks-cluster"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.86.1"
    }
  }
}
