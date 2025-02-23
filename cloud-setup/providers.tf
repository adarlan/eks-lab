provider "tfe" {}

provider "github" {}

provider "aws" {
  region = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = var.aws_default_tags
  }
}
