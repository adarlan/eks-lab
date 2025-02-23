provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.aws_default_tags
  }
}
