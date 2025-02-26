data "aws_iam_policy_document" "terraform_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.terraform_oidc_provider.arn]
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
      values   = ["organization:${var.hcp_terraform_organization}:project:${tfe_project.project.name}:workspace:*:run_phase:*"]
    }
  }
}

resource "aws_iam_role" "terraform_role" {
  name               = "${local.base_name}-terraform-role"
  assume_role_policy = data.aws_iam_policy_document.terraform_assume_role.json
}

resource "aws_iam_role_policy" "terraform_role_permissions" {
  role   = aws_iam_role.terraform_role.name
  policy = data.aws_iam_policy_document.terraform_role_permissions.json
}

data "aws_iam_policy_document" "terraform_role_permissions" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions   = toset(concat(values(local.aws_permissions)...))
  }
}
