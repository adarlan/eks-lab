terraform {
  backend "s3" {
    bucket         = "__TERRAFORM_BACKEND_S3_BUCKET__"
    key            = "__PLATFORM_NAME__-eks-cluster.tfstate"
    region         = "__TERRAFORM_BACKEND_S3_REGION__"
    dynamodb_table = "__TERRAFORM_BACKEND_S3_DYNAMODB_TABLE__"
  }
}
