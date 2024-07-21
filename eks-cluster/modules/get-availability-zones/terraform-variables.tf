variable "eligible_zones" {
  type    = list(string)
  default = []
  # TODO description: eligible_zones = ["a", "b", "c"]
}

variable "max_selected_zones" {
  type    = number
  default = 0
}
