locals {
  shared_variables = merge(
    {
      TF_VAR_aws_region       = var.aws_region
      TF_VAR_aws_default_tags = jsonencode({ project = var.github_repository })
      TF_VAR_project          = var.github_repository
      TF_VAR_cluster_name     = var.github_repository
      TF_VAR_cluster_administrators = jsonencode({
        iam_principal_arns = [data.aws_caller_identity.current.arn]
        iam_role_names = [
          aws_iam_role.terraform_role.name,
          aws_iam_role.github_role.name,
        ]
      })
      TF_VAR_acme_email = var.acme_email
      TF_VAR_domain     = var.domain
      TF_VAR_hosts      = jsonencode([for k, v in var.hosts : v])
    },
    {
      for k, v in var.hosts : "TF_VAR_${k}_host" => v
    },
    {
      TFC_AWS_PROVIDER_AUTH = true
      TFC_AWS_RUN_ROLE_ARN  = aws_iam_role.terraform_role.arn
    }
  )
}

resource "tfe_variable_set" "shared_variables" {
  name              = "shared-variables"
  organization      = var.hcp_terraform_organization
  parent_project_id = tfe_project.project.id
}

resource "tfe_variable" "shared_variable" {
  for_each = local.shared_variables

  category        = "env"
  key             = each.key
  value           = each.value
  variable_set_id = tfe_variable_set.shared_variables.id
}

resource "tfe_workspace_variable_set" "shared_variables" {
  for_each = local.workspace_names

  variable_set_id = tfe_variable_set.shared_variables.id
  workspace_id    = tfe_workspace.workspace[each.value].id
}
