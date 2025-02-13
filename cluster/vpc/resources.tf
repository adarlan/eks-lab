# -----------------------------------------------
# VPC
# -----------------------------------------------

resource "aws_vpc" "vpc" {

  cidr_block = var.vpc_cidr_block

  enable_dns_support   = true
  enable_dns_hostnames = true
  # https://docs.aws.amazon.com/vpc/latest/userguide/vpc-dns.html#vpc-dns-support
  # enable_dns_support and enable_dns_hostnames must be enabled for EFS (?)

  tags = {
    Name = var.vpc_name
  }
}

# -----------------------------------------------
# Internet gateway
# -----------------------------------------------

resource "aws_internet_gateway" "internet_gateway" {

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.vpc_name}-internet-gateway"
  }
}
