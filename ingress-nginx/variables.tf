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
}
