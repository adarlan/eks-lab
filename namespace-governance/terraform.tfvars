namespaces = {

  default = {
    skip_creation = true
    max_pod_count = 0
    cpu = {
      requests = { quota = 0, default = 0, min = 0 }
      limits   = { quota = 0, default = 0, max = 0 }
    }
    memory = {
      requests = { quota = 0, default = 0, min = 0 }
      limits   = { quota = 0, default = 0, max = 0 }
    }
    max_pvc_count = 0
    storage       = { quota = 0, min = 0, max = 0 }
  }

  monitoring = {
    max_pod_count = 100
    cpu = {
      requests = { quota = "1000m", default = "100m", min = "10m" }
      limits   = { quota = "2000m", default = "500m", max = "1000m" }
    }
    memory = {
      requests = { quota = "2Gi", default = "128Mi", min = "16Mi" }
      limits   = { quota = "4Gi", default = "512Mi", max = "1Gi" }
    }
    max_pvc_count = 4
    storage       = { quota = "8Gi", min = "1Gi", max = "4Gi" }
  }

  argocd = {
    max_pod_count = 16
    cpu = {
      requests = { quota = "500m", default = "50m", min = "10m" }
      limits   = { quota = "750m", default = "75m", max = "100m" }
    }
    memory = {
      requests = { quota = "512Mi", default = "64Mi", min = "16Mi" }
      limits   = { quota = "1Gi", default = "128Mi", max = "256Mi" }
    }
    max_pvc_count = 4
    storage       = { quota = "8Gi", min = "1Gi", max = "4Gi" }
  }

  ingress = {
    max_pod_count = 5
    cpu = {
      requests = { quota = "50m", default = "10m", min = "5m" }
      limits   = { quota = "100m", default = "25m", max = "50m" }
    }
    memory = {
      requests = { quota = "64Mi", default = "16Mi", min = "8Mi" }
      limits   = { quota = "128Mi", default = "32Mi", max = "64Mi" }
    }
    max_pvc_count = 0
    storage       = { quota = 0, min = 0, max = 0 }
  }

  cert-manager = {
    max_pod_count = 5
    cpu = {
      requests = { quota = "50m", default = "10m", min = "5m" }
      limits   = { quota = "100m", default = "25m", max = "50m" }
    }
    memory = {
      requests = { quota = "64Mi", default = "16Mi", min = "8Mi" }
      limits   = { quota = "128Mi", default = "32Mi", max = "64Mi" }
    }
    max_pvc_count = 0
    storage       = { quota = 0, min = 0, max = 0 }
  }
}
