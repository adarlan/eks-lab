variable "namespace" {
  type    = string
  default = "velero"
}

variable "helm_release_name" {
  type    = string
  default = "velero"
}

variable "aws_iam_user_name" {
  type = string
}

variable "aws_s3_bucket_name" {
  type        = string
  description = "Tha name of an existing bucket"
}
