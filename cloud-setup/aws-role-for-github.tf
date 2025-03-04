data "aws_iam_policy_document" "github_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_oidc_provider.arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${local.github_owner}/${var.github_repository}:ref:refs/heads/main"]
    }
  }
}

resource "aws_iam_role" "github_role" {
  name               = "${local.base_name}-github-role"
  assume_role_policy = data.aws_iam_policy_document.github_assume_role.json
}

resource "aws_iam_role_policy" "github_role_permissions" {
  role   = aws_iam_role.github_role.name
  policy = data.aws_iam_policy_document.github_role_permissions.json
}

data "aws_iam_policy_document" "github_role_permissions" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions   = [

      # Resource: TODO
      "eks:DescribeCluster",

      # Resource: *
      "ecr:GetAuthorizationToken",

      # Resource: arn:aws:ecr:REGION:ACCOUNT_ID:repository/GITHUB_REPOSITORY-*
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
  }
}
