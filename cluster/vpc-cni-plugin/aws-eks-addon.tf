resource "aws_eks_addon" "addon" {
  cluster_name = var.cluster_name
  addon_name   = "vpc-cni"
}
