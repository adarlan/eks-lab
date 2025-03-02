locals {
  ecr_repositories = toset([
    "crud-api-post",
    "crud-api-get",
    "crud-api-put",
    "crud-api-delete",
    "crud-client-post",
    "crud-client-get",
    "crud-client-put",
    "crud-client-delete",
  ])
}

resource "aws_ecr_repository" "ecr_repository" {
  for_each = local.ecr_repositories

  name = "${var.github_repository}-${each.key}"
}
