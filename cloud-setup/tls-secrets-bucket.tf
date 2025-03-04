resource "aws_s3_bucket" "tls_secrets_bucket" {
  bucket = "${var.github_repository}-tls-secrets-${data.aws_caller_identity.current.account_id}"
}
