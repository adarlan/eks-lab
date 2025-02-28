variable "aws_region" {
  type = string
}

variable "aws_default_tags" {
  type = map(string)
}

variable "cluster_name" {
  type = string
}

variable "ingress_class_name" {
  type = string
}

variable "cluster_issuer_name" {
  type = string
}

variable "argocd_host" {
  type = string
}

variable "github_repository" {
  type = string
}

variable "repository_deploy_key" {
  type      = string
  sensitive = true
}

variable "repository_ssh_clone_url" {
  type = string
}
