locals {
  addons = toset([
    "coredns",
    "kube-proxy",
    "vpc-cni",
    "aws-ebs-csi-driver",
  ])
}

data "aws_eks_addon_version" "addon_version" {
  for_each = local.addons

  addon_name         = each.value
  kubernetes_version = aws_eks_cluster.cluster.version
  most_recent        = true
}

resource "aws_eks_addon" "addon" {
  for_each   = local.addons
  depends_on = [aws_eks_node_group.node_group]

  cluster_name  = aws_eks_cluster.cluster.name
  addon_name    = each.value
  addon_version = data.aws_eks_addon_version.addon_version[each.value].version
}

# # -----------------------------------------------
# # CoreDNS
# # -----------------------------------------------

# resource "aws_eks_addon" "coredns" {
#   depends_on = [aws_eks_node_group.node_group]

#   cluster_name = aws_eks_cluster.cluster.name
#   addon_name   = "coredns"
# }

# # -----------------------------------------------
# # Kube Proxy
# # -----------------------------------------------

# resource "aws_eks_addon" "kube_proxy" {
#   depends_on = [aws_eks_node_group.node_group]

#   cluster_name = aws_eks_cluster.cluster.name
#   addon_name   = "kube-proxy"
# }

# # -----------------------------------------------
# # VPC CNI plugin
# # -----------------------------------------------

# resource "aws_eks_addon" "vpc_cni" {
#   depends_on = [aws_eks_node_group.node_group]

#   cluster_name = aws_eks_cluster.cluster.name
#   addon_name   = "vpc-cni"
# }

# # -----------------------------------------------
# # EBS CSI driver
# # -----------------------------------------------

# resource "aws_eks_addon" "ebs_csi_driver" {
#   depends_on = [aws_eks_node_group.node_group]

#   cluster_name  = aws_eks_cluster.cluster.name
#   addon_name    = "aws-ebs-csi-driver"
#   addon_version = data.aws_eks_addon_version.ebs_csi_driver.version
# }

# data "aws_eks_addon_version" "ebs_csi_driver" {
#   addon_name         = "aws-ebs-csi-driver"
#   kubernetes_version = aws_eks_cluster.cluster.version
#   most_recent        = true
# }

resource "aws_iam_role_policy_attachment" "node_group_role_ebs_csi_driver_policy_attachment" {
  count = contains(local.addons, "aws-ebs-csi-driver") ? 1 : 0

  role       = aws_iam_role.node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# # ------------------

# # TODO pod identity agent?
