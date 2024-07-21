aws_region = "__AWS_REGION__"

aws_default_tags = {
  IaCRepository = "github.com/__GITHUB_OWNER__/__PLATFORM_NAME__-eks-cluster"
}

vpc_name       = "__PLATFORM_NAME__-vpc"
vpc_cidr_block = "10.0.0.0/16"

cluster_name = "__PLATFORM_NAME__-cluster"

# IAM users who will be given the cluster administrator policy
cluster_administrators = [
  "__AWS_IAM_USER__",
]
