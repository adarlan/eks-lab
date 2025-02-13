# This policy is typically used in scenarios where the Kubernetes workloads need to interact with Route 53 for DNS management.
# 
# Common use cases include:
# 
# - External-DNS: If you are using a Kubernetes component like External-DNS,
#   which automatically manages DNS records for services in your Kubernetes cluster.
#   External-DNS updates Route 53 records to reflect the state of the services in the cluster.
# 
# - Service Discovery: In cases where services within the Kubernetes cluster need to be discoverable via DNS,
#   this policy ensures that the necessary DNS records can be dynamically updated.
# 
# - Automated DNS Management: Any automated process running in the node group that needs to create,
#   update, or delete DNS records in Route 53.

# TODO make it conditional with var.attach_dns_management_policy

resource "aws_iam_policy" "dns_management_policy" {
  policy = data.aws_iam_policy_document.dns_management_policy_document.json
  name   = "dns-management-policy-for-${var.role_name}"
}

resource "aws_iam_role_policy_attachment" "dns_management_policy_attachment" {
  role       = var.role_name
  policy_arn = aws_iam_policy.dns_management_policy.arn
}

data "aws_iam_policy_document" "dns_management_policy_document" {

  statement {
    effect    = "Allow"
    actions   = ["route53:ChangeResourceRecordSets"]
    resources = ["arn:aws:route53:::hostedzone/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
    ]
    resources = ["*"]
  }
}
