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
