#Bucket policy - Read-only for all
data "aws_iam_policy_document" "allow_read_all" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = ["s3:GetObject"]

    resources = [
      "${aws_s3_bucket.swnl.arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "oidc_github_policy"{
  statement {
    principals {
      type = "AWS"
      identifiers = aws_iam_openid_connect_provider.github_oidc.arn
    }

    "Version": "2012-10-17",
    "Statement": [
      {            
        "Effect": "Allow",
        "Principal": {
          "Federated": "aws_iam_openid_connect_provider.github_oidc.arn"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
            "token.actions.githubusercontent.com:sub": "repo:ruggedzen/Cloud-Resume-Challenge-AWS:ref:refs/heads/main"
          }
        }
      }
    ] 
  }
}