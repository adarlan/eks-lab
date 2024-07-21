resource "aws_eks_cluster" "cluster" {

  depends_on = [
    aws_iam_role_policy_attachment.cluster_role_AmazonEKSClusterPolicy
  ]

  name = local.cluster_name

  version = "1.29"
  # End of standard support for Kubernetes version 1.29 is March 23, 2025.
  # On that date, your cluster will enter the extended support period with additional fees.
  # For more information, see the pricing page:
  # https://aws.amazon.com/eks/pricing/

  role_arn = aws_iam_role.cluster_role.arn

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.cluster_security_group.id]

    endpoint_private_access = true

    endpoint_public_access = true
    public_access_cidrs    = ["0.0.0.0/0"]
    # TODO disable public endpoint and use only the private endpoint to access the cluster via teleport?
    # think about the application deployment workflow
  }

  access_config {

    authentication_mode = "API"
    # The authentication mode for the cluster.
    # Valid values are:
    # - CONFIG_MAP
    # - API
    # - API_AND_CONFIG_MAP

    bootstrap_cluster_creator_admin_permissions = false
    # Whether or not to bootstrap the access config values to the cluster.
    # Default is true.
    # It needs to be set to false because the user who creates the cluster
    # is not the same user who will deploy tools to the cluster.
  }
}
