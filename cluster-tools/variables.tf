variable "cluster_name" {
  type = string
}

variable "aws_default_tags" {
  type = map(string)
}

variable "domain_name" {
  type = string
}

variable "create_route53_zone" {
  type = bool
}

# variable "ingress_hosts" {
#   type = list(string)
# }

variable "aws_region" {
  type = string
}

variable "loki_s3_bucket_name" {
  type = string
}

variable "acme_email" {
  type = string
}
