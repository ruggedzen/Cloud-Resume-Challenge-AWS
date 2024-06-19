resource "aws_iam_openid_connect_provider" "github_oidc" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = []
}

resource "aws_iam_role" "role_github" {
  name = "TestOIDCRole"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/CloudFrontFullAccess",
  ]
  assume_role_policy = data.aws_iam_policy_document.oidc_github_policy.json
}