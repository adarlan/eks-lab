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
