# -----------------------------------------------
# Node group role
# -----------------------------------------------

locals {
  node_group_policies = toset([
    "AmazonEKSWorkerNodePolicy",
    "AmazonEKSWorkerNodePolicy",
    "AmazonEKS_CNI_Policy",
    "AmazonEC2ContainerRegistryReadOnly",
  ])
}

data "aws_iam_policy_document" "node_group_assume_role_policy_document" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "node_group_role" {
  name               = "${var.cluster_name}-node-group-role"
  assume_role_policy = data.aws_iam_policy_document.node_group_assume_role_policy_document.json
}

resource "aws_iam_role_policy_attachment" "node_group_policy_attachment" {
  for_each = local.node_group_policies

  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
  role       = aws_iam_role.node_group_role.name
}

# -----------------------------------------------------------------------------
# Node group DNS management policy
# -----------------------------------------------------------------------------
#
# This policy is typically used in scenarios where the Kubernetes workloads
# need to interact with Route 53 for DNS management.
# 
# Common use cases include:
# 
# - External-DNS: If you are using a Kubernetes component like External-DNS,
#   which automatically manages DNS records for services in your Kubernetes
#   cluster. External-DNS updates Route 53 records to reflect the state of the
#   services in the cluster.
# 
# - Service Discovery: In cases where services within the Kubernetes cluster
#   need to be discoverable via DNS, this policy ensures that the necessary DNS
#   records can be dynamically updated.
# 
# - Automated DNS Management: Any automated process running in the node group
#   that needs to create, update, or delete DNS records in Route 53.
#
# -----------------------------------------------------------------------------

# TODO Not sure if cert-manager needs this policy, but I don't think so

# TODO Make it conditional with var.enable_node_group_dns_management_policy

data "aws_iam_policy_document" "node_group_dns_management_policy_document" {

  statement {
    effect = "Allow"
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
    ]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["route53:ChangeResourceRecordSets"]
    resources = ["arn:aws:route53:::hostedzone/*"]
  }
}

resource "aws_iam_policy" "node_group_dns_management_policy" {
  name   = "${aws_iam_role.node_group_role.name}-dns-management-policy"
  policy = data.aws_iam_policy_document.node_group_dns_management_policy_document.json
}

resource "aws_iam_role_policy_attachment" "node_group_dns_management_policy_attachment" {
  role       = aws_iam_role.node_group_role.name
  policy_arn = aws_iam_policy.node_group_dns_management_policy.arn
}
