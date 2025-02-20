variable "aws_provider_config" {
  type = object({
    default_tags = map(string)
    region       = string
    access_key   = string
    secret_key   = string
  })
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
