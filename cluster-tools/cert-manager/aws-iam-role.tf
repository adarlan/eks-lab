# This role is necessary to solve the DNS-01 challenge.

resource "aws_iam_role" "role" {
  name               = "cert-manager-route53-access-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${local.service_account_name}"]
    }
  }
}

locals {
  service_account_name = "cert-manager"
  # TODO is it always "cert-manager"? Or is the release name? Or the namespace?
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_policy" "policy" {
  name   = "cert-manager-route53-access-policy"
  policy = data.aws_iam_policy_document.policy_statements.json
}

data "aws_iam_policy_document" "policy_statements" {

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
    resources = ["arn:aws:route53:::hostedzone/${data.aws_route53_zone.zone.id}"]
    # TODO var.zone_id instead of data.aws_route53_zone.zone.id?
  }
}
