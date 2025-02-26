resource "aws_iam_openid_connect_provider" "terraform_oidc_provider" {
  url            = "https://app.terraform.io"
  client_id_list = ["aws.workload.identity"]
}

resource "aws_iam_openid_connect_provider" "github_oidc_provider" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}
