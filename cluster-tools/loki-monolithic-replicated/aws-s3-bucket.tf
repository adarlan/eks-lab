resource "aws_s3_bucket" "prod" {
  for_each = var.is_prod ? { "${var.aws_s3_bucket_name}" = {} } : {}

  bucket = var.aws_s3_bucket_name

  force_destroy = false

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket" "non_prod" {
  for_each = var.is_prod ? {} : { "${var.aws_s3_bucket_name}" = {} }

  bucket = var.aws_s3_bucket_name

  force_destroy = true

  lifecycle {
    prevent_destroy = false
  }
}

# TODO Follow discussion: Allow overriding lifecycle.prevent_destroy with environment variable #30957
# https://github.com/hashicorp/terraform/issues/30957
