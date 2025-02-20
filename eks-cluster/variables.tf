variable "aws_provider_config" {
  type = object({
    default_tags = map(string)
    region       = string
    access_key   = string
    secret_key   = string
  })
  sensitive = true
}

variable "project" {
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
