terraform {
  required_version = "1.10.5"

  cloud {
    # organization = "<ORGANIZATION>"
    # workspaces { name = "<PROJECT>-vpc-network" }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.86.1"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.aws_default_tags
  }
}
