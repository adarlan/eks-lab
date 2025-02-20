terraform {
  required_version = "1.10.5"

  cloud {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.86.1"
    }
  }
}

provider "aws" {

  region = var.aws_provider_config.region

  access_key = var.aws_provider_config.access_key
  secret_key = var.aws_provider_config.secret_key

  default_tags {
    tags = var.aws_provider_config.default_tags
  }
}
