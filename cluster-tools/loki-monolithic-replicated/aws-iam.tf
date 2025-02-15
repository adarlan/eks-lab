resource "aws_iam_user" "user" {
  name = var.aws_iam_user_name
}

resource "aws_iam_access_key" "access_key" {
  user = aws_iam_user.user.name
}

resource "aws_iam_user_policy" "user_policy" {
  name   = aws_iam_user.user.name
  user   = aws_iam_user.user.name
  policy = data.aws_iam_policy_document.user_policy_document.json
}

data "aws_iam_policy_document" "user_policy_document" {

  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.aws_s3_bucket_name}"]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["arn:aws:s3:::${var.aws_s3_bucket_name}/*"]
  }
}
