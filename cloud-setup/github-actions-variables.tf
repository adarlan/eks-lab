resource "github_actions_variable" "TF_CLOUD_ORGANIZATION" {
  variable_name = "TF_CLOUD_ORGANIZATION"
  repository    = var.github_repository
  value         = var.hcp_terraform_organization
}

resource "github_actions_variable" "TF_CLOUD_PROJECT" {
  variable_name = "TF_CLOUD_PROJECT"
  repository    = var.github_repository
  value         = tfe_project.project.name
}

resource "github_actions_variable" "AWS_ROLE_TO_ASSUME" {
  variable_name = "AWS_ROLE_TO_ASSUME"
  repository    = var.github_repository
  value         = aws_iam_role.github_role.arn
}

resource "github_actions_variable" "AWS_REGION" {
  variable_name = "AWS_REGION"
  repository    = var.github_repository
  value         = var.aws_region
}

resource "github_actions_variable" "EKS_CLUSTER_NAME" {
  variable_name = "EKS_CLUSTER_NAME"
  repository    = var.github_repository
  value         = var.github_repository # TODO local.cluster_name?
}
