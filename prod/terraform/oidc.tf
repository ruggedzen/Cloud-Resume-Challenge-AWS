#Create web idenetity
resource "aws_iam_openid_connect_provider" "github_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["1b511abead59c6ce207077c0bf0e0043b1382612"]
  url             = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_role" "github_oidc_role" {
  name                 = "GithubActions-WebIdentity-Role"
  assume_role_policy   = data.aws_iam_policy_document.oidc_role.json
  managed_policy_arns  = ["arn:aws:iam::aws:policy/AWSLambda_FullAccess", "arn:aws:iam::aws:policy/AmazonS3FullAccess", "arn:aws:iam::aws:policy/CloudFrontFullAccess"]
  max_session_duration = 3600
  path                 = "/"
  depends_on           = [aws_iam_openid_connect_provider.github_oidc]
}
