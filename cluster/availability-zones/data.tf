data "aws_region" "region" {}

data "aws_availability_zones" "available_zones" {
  state = "available"
}
