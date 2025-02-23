data "aws_iam_policy_document" "assume_role_policy" {
  for_each = local.workspaces

  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.oidc_provider.arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "app.terraform.io:aud"
      values   = ["aws.workload.identity"]
    }

    condition {
      test     = "StringLike"
      variable = "app.terraform.io:sub"
      values   = ["organization:${var.organization}:project:${var.project}:workspace:${each.key}:run_phase:*"]
    }
  }
}

resource "aws_iam_role" "role" {
  for_each = local.workspaces

  name               = each.key
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy[each.key].json
}

resource "aws_iam_role_policy" "role_permissions" {
  for_each = local.workspaces

  role   = aws_iam_role.role[each.key].name
  policy = data.aws_iam_policy_document.role_permissions[each.key].json
}

data "aws_iam_policy_document" "role_permissions" {
  for_each = local.workspaces

  statement {
    effect    = "Allow"
    actions   = each.value.aws_permissions
    resources = ["*"]
  }
}
