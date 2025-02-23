resource "aws_iam_openid_connect_provider" "oidc_provider" {
  url            = "https://app.terraform.io"
  client_id_list = ["aws.workload.identity"]
}
