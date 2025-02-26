variable "github_repository" {
  type        = string
  description = "GitHub repository"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "hcp_terraform_organization" {
  type        = string
  description = "HCP Terraform organization"
}

variable "domain" {
  type        = string
  description = "Registered domain"
}

variable "hosts" {
  type = map(string)
  description = "Hosts for applications and tools"
}

variable "acme_email" {
  type        = string
  description = "ACME email"
}
