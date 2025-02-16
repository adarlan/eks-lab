locals {
  cluster_security_group_name = "${var.cluster_name}-security-group"
  cluster_role_name           = "${var.cluster_name}-role"
  cluster_oidc_provider_name  = "${var.cluster_name}-oidc-provider"
}

# Cluster

resource "aws_eks_cluster" "cluster" {

  depends_on = [
    aws_iam_role_policy_attachment.cluster_role_AmazonEKSClusterPolicy
  ]

  name = var.cluster_name

  version = "1.31"

  role_arn = aws_iam_role.cluster_role.arn

  vpc_config {

    subnet_ids = concat(
      values(aws_subnet.public)[*].id,
      values(aws_subnet.private)[*].id,
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

# Access entries

# TODO could simplify by enabling bootstrap_cluster_creator_admin_permissions
# and removing the access entries

locals {
  cluster_administrators_map = {
    for name in var.cluster_administrators : name => {}
  }
}

resource "aws_eks_access_entry" "access_entries" {
  for_each = local.cluster_administrators_map

  cluster_name  = aws_eks_cluster.cluster.name
  principal_arn = data.aws_iam_user.iam_users[each.key].arn
  type          = "STANDARD"
}

data "aws_iam_user" "iam_users" {
  for_each = local.cluster_administrators_map

  user_name = each.key
}

resource "aws_eks_access_policy_association" "cluster_admin_policy_associations" {
  for_each = local.cluster_administrators_map

  cluster_name  = aws_eks_cluster.cluster.name
  principal_arn = data.aws_iam_user.iam_users[each.key].arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

# Security group

resource "aws_security_group" "cluster_security_group" {

  name        = local.cluster_security_group_name
  description = "Allow TLS inbound traffic"

  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = local.cluster_security_group_name
  }
}

# Cluster role

resource "aws_iam_role" "cluster_role" {
  name               = local.cluster_role_name
  assume_role_policy = data.aws_iam_policy_document.cluster_role_assume_role_policy.json
}

data "aws_iam_policy_document" "cluster_role_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "cluster_role_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_role.name
}

resource "aws_iam_role_policy_attachment" "cluster_role_AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster_role.name
}
