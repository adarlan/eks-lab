resource "helm_release" "velero" {

  name      = var.helm_release_name
  namespace = var.namespace

  create_namespace = true

  repository = "https://vmware-tanzu.github.io/helm-charts"
  chart      = "velero"
  version    = "7.1.0"

  timeout       = 240
  wait          = true
  wait_for_jobs = true

  dynamic "set" {
    for_each = local.helm_values
    content {
      name  = set.key
      value = set.value
    }
  }
}

locals {
  helm_values = {
    "credentials.secretContents.cloud" = <<EOF
[default]
aws_access_key_id=<REDACTED>
aws_secret_access_key=<REDACTED>
EOF

    "configuration.backupStorageLocation[0].name"          = "<BACKUP STORAGE LOCATION NAME>"
    "configuration.backupStorageLocation[0].provider"      = "<PROVIDER NAME>"
    "configuration.backupStorageLocation[0].bucket"        = "<BUCKET NAME>"
    "configuration.backupStorageLocation[0].config.region" = "<REGION>"

    "configuration.volumeSnapshotLocation[0].name"          = "<VOLUME SNAPSHOT LOCATION NAME>"
    "configuration.volumeSnapshotLocation[0].provider"      = "<PROVIDER NAME>"
    "configuration.volumeSnapshotLocation[0].config.region" = "<REGION>"

    "initContainers[0].name"                      = "velero-plugin-for-<PROVIDER NAME>"
    "initContainers[0].image"                     = "velero/velero-plugin-for-<PROVIDER NAME>:<PROVIDER PLUGIN TAG>"
    "initContainers[0].volumeMounts[0].mountPath" = "/target"
    "initContainers[0].volumeMounts[0].name"      = "plugins"
  }
}
