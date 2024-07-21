resource "aws_iam_role_policy_attachment" "node_group_role_policy_attachment" {
  for_each = toset([
    for parts in [for arn in data.aws_eks_node_group.node_group : split("/", arn.node_role_arn)] :
    parts[1]
    ]
  )

  role       = each.value # role name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

data "aws_eks_node_group" "node_group" {
  for_each = data.aws_eks_node_groups.node_groups.names

  cluster_name    = data.aws_eks_cluster.cluster.name
  node_group_name = each.value
}

data "aws_eks_node_groups" "node_groups" {
  cluster_name = data.aws_eks_cluster.cluster.name
}

# TODO ? This module should be part of the node-group module,
# so that we can enable the ebs-csi-driver for specific node groups.
