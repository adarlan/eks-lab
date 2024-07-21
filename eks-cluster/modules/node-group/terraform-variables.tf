variable "cluster_name" {
  type = string
}

variable "node_group_name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "instance_type" {
  type = string
}

variable "instance_count" {
  type = number
}

variable "node_role" {
  type = string
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

variable "node_group_role_arn" {
  type = string
}
