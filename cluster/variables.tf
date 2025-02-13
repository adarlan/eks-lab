variable "vpc_name" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "cluster_administrators" {
  description = "IAM users who will be given the cluster administrator policy"
  type        = list(string)
  default     = []
}

variable "aws_default_tags" {
  type = map(string)
}

variable "aws_region" {
  type = string
}
