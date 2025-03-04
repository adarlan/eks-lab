output "tls_secrets_bucket_name" {
  value = aws_s3_bucket.tls_secrets_bucket.bucket
}

output "cluster_name" {
  value = var.github_repository # TODO local.cluster_name?
}

output "aws_region" {
  value = var.aws_region
}
