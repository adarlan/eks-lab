variable "registered_domain" {
  type = string
}

variable "record_names" {
  type        = list(string)
  description = "The subdomains without the registered domain part. Examples: 'foo', 'bar', '*', '' (empty for domain)"
}

variable "load_balancer_name" {
  type = string
}
