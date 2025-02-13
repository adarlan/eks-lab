variable "vpc_id" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "eks_cluster_name" {
  type = string
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

variable "internet_gateway_id" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}
