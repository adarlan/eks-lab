locals {
  addons = toset([
    "coredns",
    "kube-proxy",
    "vpc-cni",
    "aws-ebs-csi-driver",
  ])
}

# TODO pod identity agent?

data "aws_eks_addon_version" "addon_version" {
  for_each = local.addons

  addon_name         = each.value
  kubernetes_version = aws_eks_cluster.cluster.version
  most_recent        = true
}

resource "aws_eks_addon" "addon" {
  depends_on = [aws_eks_node_group.node_group]
  for_each   = local.addons

  cluster_name  = aws_eks_cluster.cluster.name
  addon_name    = each.value
  addon_version = data.aws_eks_addon_version.addon_version[each.value].version
}

resource "aws_iam_role_policy_attachment" "node_group_ebs_csi_driver_policy_attachment" {
  count = contains(local.addons, "aws-ebs-csi-driver") ? 1 : 0

  role       = aws_iam_role.node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
