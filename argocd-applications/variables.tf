variable "aws_region" {
  type = string
}

variable "aws_default_tags" {
  type = map(string)
}

variable "cluster_name" {
  type = string
}

variable "hello_world_host" {
  type = string
}

variable "crud_api_host" {
  type = string
}

variable "repository_ssh_clone_url" {
  type = string
}
