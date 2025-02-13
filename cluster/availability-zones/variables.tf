variable "eligible_zones" {
  description = "Example: [\"a\", \"b\", \"c\"]"
  type        = list(string)
  default     = []
}

variable "max_selected_zones" {
  type    = number
  default = 0
}
