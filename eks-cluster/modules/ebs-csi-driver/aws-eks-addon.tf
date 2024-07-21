resource "aws_eks_addon" "addon" {
  cluster_name  = data.aws_eks_cluster.cluster.name
  addon_name    = "aws-ebs-csi-driver"
  addon_version = data.aws_eks_addon_version.addon_version.version
}

data "aws_eks_addon_version" "addon_version" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = data.aws_eks_cluster.cluster.version
  most_recent        = true
}
