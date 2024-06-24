#Create web idenetity
resource "aws_iam_openid_connect_provider" "github_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["1b511abead59c6ce207077c0bf0e0043b1382612"]
  url             = "https://token.actions.githubusercontent.com"
}

#Create github role
resource "aws_iam_role" "github_oidc_role" {
  depends_on = [ aws_iam_openid_connect_provider.github_oidc ]
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          "token.actions.githubusercontent.com:sub" = "repo:ruggedzen/Cloud-Resume-Challenge-AWS:ref:refs/heads/main"
        }
      }
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::339713009188:oidc-provider/token.actions.githubusercontent.com"
      }
    }]
    Version = "2012-10-17"
  })
  description           = null
  force_detach_policies = false
  managed_policy_arns   = ["arn:aws:iam::aws:policy/AWSLambda_FullAccess", "arn:aws:iam::aws:policy/AmazonS3FullAccess", "arn:aws:iam::aws:policy/CloudFrontFullAccess"]
  max_session_duration  = 3600
  name                  = "GithubActions-WebIdentity-Role"
  path                  = "/"
  permissions_boundary  = null
}