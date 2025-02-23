locals {
  cluster_security_group_name = "${var.cluster_name}-security-group"
  cluster_role_name           = "${var.cluster_name}-role"
  cluster_oidc_provider_name  = "${var.cluster_name}-oidc-provider"
}

resource "aws_eks_cluster" "cluster" {

  depends_on = [
    aws_iam_role_policy_attachment.cluster_role_AmazonEKSClusterPolicy
  ]

  name = var.cluster_name

  version = "1.31"

  role_arn = aws_iam_role.cluster_role.arn

  vpc_config {

    subnet_ids = concat(
      data.aws_subnets.public.ids,
      data.aws_subnets.private.ids,
    )

    security_group_ids = [aws_security_group.cluster_security_group.id]

    endpoint_private_access = true

    endpoint_public_access = true
    public_access_cidrs    = ["0.0.0.0/0"]
    # TODO disable public endpoint and use only the private endpoint to access the cluster via teleport?
    # think about the application deployment workflow
  }

  access_config {
    authentication_mode = "API"

    bootstrap_cluster_creator_admin_permissions = false
    # It needs to be set to false because the user who creates the cluster
    # is not the same user who will administrate and deploy components to the cluster.
  }
}
