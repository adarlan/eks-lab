data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "tls_secrets_bucket" {
  bucket = "${var.project}-tls-secrets-${data.aws_caller_identity.current.account_id}"
}

output "tls_secrets_bucket_name" {
  value = aws_s3_bucket.tls_secrets_bucket.bucket
}
