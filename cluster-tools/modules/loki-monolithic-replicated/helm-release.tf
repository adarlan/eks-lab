resource "helm_release" "loki" {
  depends_on = [
    aws_s3_bucket.prod,
    aws_s3_bucket.non_prod
  ]

  name = "loki"

  namespace        = "monitoring"
  create_namespace = true

  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  # version    = "5.43.3"

  version = "6.6.3" # Corresponds to Loki 3.0.0

  timeout       = 1200
  wait          = true
  wait_for_jobs = true

  values = [
    file("${path.module}/helm-values.yaml")
  ]

  # set {
  #   name  = "singleBinary.replicas"
  #   value = var.loki_singlebinary_replicas
  # }

  # set {
  #   name  = "loki.commonConfig.replication_factor"
  #   value = var.loki_singlebinary_replicas
  # }

  set {
    name  = "loki.storage.bucketNames.chunks"
    value = var.aws_s3_bucket_name
  }

  set {
    name  = "loki.storage.bucketNames.ruler"
    value = var.aws_s3_bucket_name
  }

  set {
    name  = "loki.storage.bucketNames.admin"
    value = var.aws_s3_bucket_name
  }

  set {
    name  = "loki.storage.s3.endpoint"
    value = "s3.${data.aws_region.current_region.name}.amazonaws.com"
  }

  set {
    name  = "loki.storage.s3.region"
    value = data.aws_region.current_region.name
  }

  set {
    name  = "loki.storage.s3.accessKeyId"
    value = aws_iam_access_key.access_key.id
  }

  set {
    name  = "loki.storage.s3.secretAccessKey"
    value = aws_iam_access_key.access_key.secret
  }
}
