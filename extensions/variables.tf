
# AWS provider

variable "aws_default_tags" {
  type = map(string)
}

variable "aws_region" {
  type = string
}

#

variable "cluster_name" {
  type = string
}

#

variable "registered_domain" {
  type = string
}

variable "record_names" {
  type        = list(string)
  description = "The subdomains without the registered domain part. Examples: 'foo', 'bar', '*', '' (empty for domain)"
}

variable "acme_email" {
  type = string
}
