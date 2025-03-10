variable "aws_region" {
  type = string
}

variable "aws_default_tags" {
  type = map(string)
}

variable "cluster_name" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "eligible_zones" {
  description = "Example: [\"a\", \"b\", \"c\"]"
  type        = list(string)
  default     = []
}

variable "max_selected_zones" {
  type    = number
  default = 0
}

variable "subnet_cidr_block_newbits" {
  description = "Example: 8"
  type        = number
}

variable "max_nat_gateway_count" {
  type    = number
  default = 1
  # TODO what is the minimum?
}
