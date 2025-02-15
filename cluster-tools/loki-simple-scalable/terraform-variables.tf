variable "aws_s3_bucket_name" {
  type = string
}

variable "aws_iam_user_name" {
  type = string
}

variable "is_prod" {
  description = "Flag to determine if the environment is production."
  type        = bool
}
