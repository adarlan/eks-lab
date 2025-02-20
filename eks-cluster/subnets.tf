data "aws_subnets" "public" {

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  filter {
    name   = "map-public-ip-on-launch"
    values = [true]
  }

  tags = {
    project = var.project

    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

data "aws_subnets" "private" {

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  filter {
    name   = "map-public-ip-on-launch"
    values = [false]
  }

  tags = {
    project = var.project

    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}
