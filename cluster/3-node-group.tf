locals {

  optimized_ami_type = var.use_gpu_optimized_ami ? "amazon-linux-2-gpu" : (
    var.use_arm64_optimized_ami ? "amazon-linux-2-arm64" : "amazon-linux-2"
  )

  node_group_name = "${var.cluster_name}-node-group"

  node_group_role_name = "${local.node_group_name}-role"

  dns_management_policy_name = "${local.node_group_role_name}-dns-management-policy"
}

# -----------------------------------------------
# Node group
# -----------------------------------------------

resource "aws_eks_node_group" "node_group" {

  cluster_name = aws_eks_cluster.cluster.name
  version      = aws_eks_cluster.cluster.version

  node_group_name = local.node_group_name
  node_role_arn   = aws_iam_role.node_group_role.arn

  subnet_ids = values(aws_subnet.private)[*].id
  # Only the private subnets
  # TODO does the cluster need public subnets?

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

data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${aws_eks_cluster.cluster.version}/${local.optimized_ami_type}/recommended/release_version"
}

# -----------------------------------------------
# Node group role
# -----------------------------------------------

resource "aws_iam_role" "node_group_role" {

  name = local.node_group_role_name

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "node_group_role_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group_role.name
}

resource "aws_iam_role_policy_attachment" "node_group_role_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group_role.name
}

resource "aws_iam_role_policy_attachment" "node_group_role_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group_role.name
}

# -----------------------------------------------
# Node group role policy for DNS management
# -----------------------------------------------

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
  name   = local.dns_management_policy_name
  policy = data.aws_iam_policy_document.dns_management_policy_document.json
}

resource "aws_iam_role_policy_attachment" "dns_management_policy_attachment" {
  role       = aws_iam_role.node_group_role.name
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
