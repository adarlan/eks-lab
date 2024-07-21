provider "aws" {

  region = var.aws_region

  default_tags {
    tags = var.aws_default_tags
  }
}

provider "kubernetes" {
  config_path = "kubeconfig"
}

provider "helm" {
  kubernetes {
    config_path = "kubeconfig"
  }
}
