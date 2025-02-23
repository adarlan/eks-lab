locals {
  managed_limit_ranges = {} # TODO
}

resource "kubernetes_limit_range" "limit_range" {
  for_each = local.managed_limit_ranges

  metadata {
    name      = each.key
    namespace = each.key
  }

  spec {

    limit {
      type = "PersistentVolumeClaim"

      min = {
        storage = each.value.storage.min
      }

      max = {
        storage = each.value.storage.max
      }
    }

    limit {
      type = "Container" # TODO type = "Pod"?

      default_request = {
        cpu    = each.value.cpu.requests.default
        memory = each.value.memory.requests.default
      }

      default = {
        cpu    = each.value.cpu.limits.default
        memory = each.value.memory.limits.default
      }

      min = {
        cpu    = each.value.cpu.requests.min
        memory = each.value.memory.requests.min
      }

      max = {
        cpu    = each.value.cpu.limits.max
        memory = each.value.memory.limits.max
      }
    }
  }
}
