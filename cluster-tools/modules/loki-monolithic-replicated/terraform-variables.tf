variable "aws_s3_bucket_name" {
  type = string
}

variable "aws_iam_user_name" {
  type = string
}

variable "loki_singlebinary_replicas" {
  type        = number
  description = "Number of replicas for the single binary to run in a replicated, highly available mode. Set this value to 2 or more."
  # TODO validation: must be >= 2
}

variable "is_prod" {
  description = "Flag to determine if the environment is production."
  type        = bool
}
