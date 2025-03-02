locals {
  ecr_repositories = toset([
    "crud-api",
    "crud-client",
  ])
}

resource "aws_ecr_repository" "ecr_repository" {
  for_each = local.ecr_repositories

  name = "${var.github_repository}-${each.key}"
}
