# -----------------------------------------------
# Node group
# -----------------------------------------------

locals {
  optimized_ami_type = var.use_gpu_optimized_ami ? "amazon-linux-2-gpu" : (
    var.use_arm64_optimized_ami ? "amazon-linux-2-arm64" : "amazon-linux-2"
  )
}

data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${aws_eks_cluster.cluster.version}/${local.optimized_ami_type}/recommended/release_version"
}

resource "aws_eks_node_group" "node_group" {

  cluster_name = aws_eks_cluster.cluster.name
  version      = aws_eks_cluster.cluster.version

  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.node_group_role.arn

  subnet_ids = data.aws_subnets.private.ids
  # Only the private subnets
  # TODO does the cluster need public subnets?
  # TODO var.node_group_public? or var.node_group_visibility??

  capacity_type  = var.use_spot_instances ? "SPOT" : "ON_DEMAND"
  instance_types = [var.instance_type]

  labels = {
    role = "private" # TODO "main"?
  }

  scaling_config {
    min_size     = var.instance_count
    desired_size = var.instance_count
    max_size     = var.instance_count
  }

  # update_config {
  #   max_unavailable = 1
  # }

  # lifecycle {
  #   ignore_changes = [scaling_config[0].desired_size]
  # }

  release_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)
}
