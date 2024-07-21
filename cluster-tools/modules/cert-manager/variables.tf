variable "registered_domain" {
  type = string
}

variable "oidc_provider_url" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "namespace" {
  type    = string
  default = "cert-manager"
}

variable "helm_release_name" {
  type    = string
  default = "cert-manager"
}
