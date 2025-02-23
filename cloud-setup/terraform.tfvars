organization = "<ORGANIZATION>"
project      = "<PROJECT>"
team         = "owners"
aws_region   = "<AWS_REGION>"
aws_default_tags = {
  project = "<PROJECT>"
}

aws_profile = "<AWS_PROFILE>"

github_repository = "<GITHUB_REPOSITORY>"

aws_permissions = {

  vpc-network = ["ec2:*"]

  eks-cluster = [
    "eks:*",
    "ec2:*",
    "iam:GetUser",
    "iam:CreateRole",
    "iam:TagRole",
    "iam:GetRole",
    "iam:ListRolePolicies",
    "iam:ListAttachedRolePolicies",
    "iam:ListInstanceProfilesForRole",
    "iam:DeleteRole",
    "iam:AttachRolePolicy",
    "iam:CreatePolicy",
    "iam:TagPolicy",
    "iam:PassRole",
    "iam:GetPolicy",
    "iam:GetPolicyVersion",
    "ssm:GetParameter",
    "iam:ListPolicyVersions",
    "iam:DeletePolicy",
    "iam:DetachRolePolicy",
  ]

  namespace-governance = [
    "eks:DescribeCluster",
  ]

  ingress-nginx = [
    "eks:DescribeCluster",
    "route53:ListHostedZones",
    "route53:GetHostedZone",
    "route53:ListTagsForResource",
    "elasticloadbalancing:DescribeLoadBalancers",
    "elasticloadbalancing:DescribeLoadBalancerAttributes",
    "elasticloadbalancing:DescribeTags",
    "route53:ChangeResourceRecordSets",
    "route53:GetChange",
    "route53:ListResourceRecordSets",
  ]

  # s3 access is for tls secret restore
  cert-manager = [
    "eks:DescribeCluster",
    "route53:ListHostedZones",
    "route53:GetHostedZone",
    "route53:ListTagsForResource",
    "s3:ListBucket",
    "s3:GetObject",
    "s3:GetObjectTagging",
    "iam:CreatePolicy",
    "iam:CreateOpenIDConnectProvider",
    "iam:TagOpenIDConnectProvider",
    "iam:TagPolicy",
    "iam:GetOpenIDConnectProvider",
    "iam:GetPolicy",
    "iam:GetPolicyVersion",
    "iam:DeleteOpenIDConnectProvider",
    "iam:ListPolicyVersions",
    "iam:DeletePolicy",
    "iam:CreateRole",
    "iam:TagRole",
    "iam:GetRole",
    "iam:ListRolePolicies",
    "iam:ListAttachedRolePolicies",
    "iam:ListInstanceProfilesForRole",
    "iam:DeleteRole",
    "iam:AttachRolePolicy",
    "iam:DetachRolePolicy",
  ]

  kube-prometheus-stack = [
    "eks:DescribeCluster",
  ]

  argo-cd = [
    "eks:DescribeCluster",
  ]
}
