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

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "swnl_lambda_policy" {
  name = "DynamoDBLambdaAccess"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "DynamoLeastPriv",
        "Action" : [
          "dynamodb:DeleteItem",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:UpdateItem"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Sid" : "LambdaLogAllow",
        "Resource" : "*",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Effect" : "Allow"
      }
    ]
  })
}