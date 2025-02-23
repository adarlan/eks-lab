locals {
  managed_resource_quotas = {} # TODO
}

resource "kubernetes_resource_quota" "resource_quota" {
  for_each = local.managed_resource_quotas

  metadata {
    name      = each.key
    namespace = each.key
  }

  spec {
    hard = {
      "pods"                   = each.value.maxPodCount
      "requests.cpu"           = each.value.cpu.requests.quota
      "requests.memory"        = each.value.memory.requests.quota
      "limits.cpu"             = each.value.cpu.limits.quota
      "limits.memory"          = each.value.memory.limits.quota
      "persistentvolumeclaims" = each.value.maxPvcCount
      "requests.storage"       = each.value.storage.quota
    }
  }
}
