variable "aws_region" {
  type = string
}

variable "aws_default_tags" {
  type = map(string)
}

variable "project" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "cluster_administrators" {
  description = "IAM principals who will be given the cluster administrator policy"
  type = object({
    iam_user_names     = optional(list(string), [])
    iam_role_names     = optional(list(string), [])
    iam_principal_arns = optional(list(string), [])
  })
  default = {}
}

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
