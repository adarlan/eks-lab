data "aws_caller_identity" "current" {}

locals {
  tls_secrets_bucket_name = "${var.cluster_name}-tls-secrets-${data.aws_caller_identity.current.account_id}"
}

data "aws_s3_objects" "tls_secrets" {
  bucket = local.tls_secrets_bucket_name
}

locals {
  tls_secret_names = toset(data.aws_s3_objects.tls_secrets.keys)
}

data "aws_s3_object" "tls_secret" {
  for_each = local.tls_secret_names

  bucket = local.tls_secrets_bucket_name
  key    = each.value
}

resource "kubernetes_manifest" "tls_secret" {
  for_each = local.tls_secret_names

  manifest = jsondecode(data.aws_s3_object.tls_secret[each.value].body)
}
