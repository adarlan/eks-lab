data "aws_vpc" "vpc" {
  tags = {
    project = var.project
  }
}
