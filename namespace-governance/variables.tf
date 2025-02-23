variable "aws_region" {
  type = string
}

variable "aws_default_tags" {
  type = map(string)
}

variable "cluster_name" {
  type = string
}

variable "namespaces" {
  type = map(object({

    skip_creation = optional(bool, false)

    max_pod_count = number # The maximum number of pods within the namespace.

    max_pvc_count = number # The maximum number of PVCs within the namespace.

    cpu = object({
      requests = object({
        quota   = string # The total amount of CPU resources that all pods within the namespace are guaranteed to have available.
        default = string # The default amount of CPU resources that each pod within the namespace is guaranteed to have available.
        min     = string # The minimum amount of CPU resources that each pod within the namespace is guaranteed to have available.
      })
      limits = object({
        quota   = string # The total amount of CPU resources that all pods within the namespace can consume.
        default = string # The default amount of CPU resources that each pod within the namespace can consume.
        max     = string # The maximum amount of CPU resources that each pod within the namespace can consume.
      })
    })

    memory = object({
      requests = object({
        quota   = string # The total amount of memory that all pods within the namespace are guaranteed to have available.
        default = string # The default amount of memory that each pod within the namespace is guaranteed to have available.
        min     = string # The minimum amount of memory that each pod within the namespace is guaranteed to have available.
      })

      limits = object({
        quota   = string # The total amount of memory that all pods within the namespace can consume.
        default = string # The default amount of memory that each pod within the namespace can consume.
        max     = string # The maximum amount of memory that each pod within the namespace can consume.
      })
    })

    storage = object({
      quota = string # The total amount of storage resources that all PVCs within the namespace can request.
      min   = string # The minimum amount of storage resources that each PVC within the namespace can request.
      max   = string # The maximum amount of storage resources that each PVC within the namespace can request.
    })
  }))
}
