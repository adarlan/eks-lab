variable "cluster_name" {
  type = string
}

variable "cluster_administrators" {
  description = "IAM users who will be given the cluster administrator policy"
  type        = list(string)
  default     = []
}

# AWS provider

variable "aws_default_tags" {
  type = map(string)
}

variable "aws_region" {
  type = string
}

# VPC network

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

# Node group

variable "instance_type" {
  type = string
}

variable "instance_count" {
  type = number
}

variable "use_spot_instances" {
  type    = bool
  default = false
}

variable "use_gpu_optimized_ami" {
  type    = bool
  default = false
  # TODO validation: conflicts with use_arm64_optimized_ami
}

variable "use_arm64_optimized_ami" {
  type    = bool
  default = false
}
