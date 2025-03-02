locals {
  workspace_names = toset([for k, v in local.aws_permissions : "${tfe_project.project.name}-${k}"])
}

resource "tfe_workspace" "workspace" {
  for_each = local.workspace_names

  name              = each.value
  organization      = var.hcp_terraform_organization
  project_id        = tfe_project.project.id
  terraform_version = "1.10.5"
}

# TODO auto_destroy_at?
# A future date/time string at which point all
# resources in a workspace will be scheduled for deletion. Must be a string
# in RFC3339 format (e.g. "2100-01-01T00:00:00Z"). Conflicts with
# auto_destroy_activity_duration. auto_destroy_at is not intended for
# workspaces containing production resources or long-lived workspaces. Since
# this attribute is in-part managed by HCP Terraform, using ignore_changes for
# this attribute may be preferred.

# TODO auto_destroy_activity_duration?
# A duration string of the period of time after workspace activity
# to automatically schedule an auto-destroy run. Must be of the form <number><unit>
# where allowed unit values are "d" and "h". Conflicts with auto_destroy_at.
