data "aws_iam_user" "cluster_administrators" {
  for_each = toset(var.cluster_administrators.iam_user_names)

  user_name = each.value
}

data "aws_iam_role" "cluster_administrators" {
  for_each = toset(var.cluster_administrators.iam_role_names)

  name = each.value
}

locals {
  cluster_administrator_arns = toset(concat(
    [for principal_arn in var.cluster_administrators.iam_principal_arns : principal_arn],
    [for user_name in var.cluster_administrators.iam_user_names : data.aws_iam_user.cluster_administrators[user_name].arn],
    [for role_name in var.cluster_administrators.iam_role_names : data.aws_iam_role.cluster_administrators[role_name].arn],
  ))
}

resource "aws_eks_access_entry" "cluster_administrators" {
  for_each = local.cluster_administrator_arns

  cluster_name  = aws_eks_cluster.cluster.name
  principal_arn = each.value
}

resource "aws_eks_access_policy_association" "cluster_admin_policy_associations" {
  for_each = local.cluster_administrator_arns

  cluster_name  = aws_eks_cluster.cluster.name
  principal_arn = each.value
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}
