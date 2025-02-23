resource "tfe_variable" "TFC_AWS_PROVIDER_AUTH" {
  for_each = local.workspaces

  category     = "env"
  workspace_id = tfe_workspace.workspace[each.key].id
  key          = "TFC_AWS_PROVIDER_AUTH"
  value        = true
}

resource "tfe_variable" "TFC_AWS_RUN_ROLE_ARN" {
  for_each = local.workspaces

  category     = "env"
  workspace_id = tfe_workspace.workspace[each.key].id
  key          = "TFC_AWS_RUN_ROLE_ARN"
  value        = aws_iam_role.role[each.key].arn
}
