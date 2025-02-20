# This role is necessary to solve the DNS-01 challenge.

resource "aws_iam_role" "cert_manager_role" {
  name               = "${local.release_name}-role"
  assume_role_policy = data.aws_iam_policy_document.cert_manager_assume_role_policy_document.json
}

data "aws_iam_policy_document" "cert_manager_assume_role_policy_document" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(local.oidc_provider_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${local.namespace}:${local.service_account_name}"]
    }
  }
}

data "aws_iam_policy_document" "cert_manager_policy_document" {

  statement {
    effect    = "Allow"
    actions   = ["route53:GetChange"]
    resources = ["arn:aws:route53:::change/*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
    ]

    resources = ["arn:aws:route53:::hostedzone/${local.route53_zone_id}"]
  }
}

resource "aws_iam_policy" "cert_manager_policy" {
  name   = "${local.release_name}-policy"
  policy = data.aws_iam_policy_document.cert_manager_policy_document.json
}

resource "aws_iam_role_policy_attachment" "cert_manager_policy_attachment" {
  role       = aws_iam_role.cert_manager_role.name
  policy_arn = aws_iam_policy.cert_manager_policy.arn
}
