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
