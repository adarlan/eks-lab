variable "aws_region" {
  type = string
}

variable "aws_default_tags" {
  type = map(string)
}

variable "cluster_name" {
  type = string
}

variable "cluster_issuer_name" {
  type = string
}

variable "acme_production" {
  type = bool
}

variable "domain" {
  type = string
}

variable "acme_email" {
  type = string
}
