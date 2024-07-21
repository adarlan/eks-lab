output "oidc_provider_url" {
  value = aws_iam_openid_connect_provider.oidc_provider.url
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.oidc_provider.arn
}
