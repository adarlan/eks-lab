
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

# variable "hosts" {
#   type = list(string)
#   description = "Examples: example.com, foo.example.com, *.example.com, *.foo.example.com"
#   # TODO validation: must be equal "${var.registered_domain}" or end with ".${var.registered_domain}"
# }

variable "acme_email" {
  type = string
}

variable "acme_production" {
  type = bool
}
