variable "cluster_name" {
  type = string
}

variable "cluster_administrators" {
  type    = list(string)
  default = []
}
