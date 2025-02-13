aws_region = "us-east-1"

aws_default_tags = {
  project = "eks-lab"
}

vpc_name       = "eks-lab"
vpc_cidr_block = "10.0.0.0/16"

cluster_name = "eks-lab"

cluster_administrators = [
  "adarlan",
]
