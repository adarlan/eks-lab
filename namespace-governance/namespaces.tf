locals {
  managed_namespaces = {
    for k, v in var.namespaces : k => v if lookup(v, "skip_creation", false) == false
  }
}

resource "kubernetes_namespace" "namespace" {
  for_each = local.managed_namespaces

  metadata {
    name = each.key
  }
}
