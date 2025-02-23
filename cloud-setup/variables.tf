variable "organization" {
  type = string
}

variable "project" {
  type = string
}

variable "aws_permissions" {
  type = map(list(string))
}

variable "team" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "aws_default_tags" {
  type = map(string)
}

variable "aws_profile" {
  type = string
}

variable "github_repository" {
  type = string
}
