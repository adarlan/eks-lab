variable "aws_region" {
  type = string
}

variable "aws_default_tags" {
  type = map(string)
}

variable "cluster_name" {
  type = string
}

variable "domain" {
  type = string
}

variable "enable_route53_zone_management" {
  type = bool
}

variable "hosts" {
  type        = list(string)
  description = "Examples: example.com, foo.example.com, *.example.com, *.foo.example.com"
  # TODO validation: must be equal "${var.domain}" or end with ".${var.domain}"
  # "*.example.com",
  # "*.foo.example.com"
  # it works for subdomains, and also for sub-subdomains, etc (foo.example.com, and also foo.bar.example.com)
}
