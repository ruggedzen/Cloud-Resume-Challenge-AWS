resource "aws_iam_role" "swnl_lambda_role" {
  name                = "CRCLambdaRole"
  assume_role_policy  = data.aws_iam_policy_document.lambda_assume_role.json
  managed_policy_arns = [aws_iam_policy.swnl_lambda_policy.arn]
}

data "archive_file" "swnl_lambda_code" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "swnl_lambda" {
  filename         = "lambda_function_payload.zip"
  function_name    = "crc_lambda"
  role             = aws_iam_role.swnl_lambda_role.arn
  source_code_hash = data.archive_file.swnl_lambda_code.output_base64sha256
  runtime          = "python3.12"
  handler          = "lambda_function.lambda_handler"

  tags = local.common_tags
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.swnl_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.swnl_api.execution_arn}/*"
}