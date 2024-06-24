resource "aws_iam_role" "swnl_lambda_role" {
  name                = "CRCLambdaRole"
  assume_role_policy  = data.aws_iam_policy_document.lambda_assume_role.json
  managed_policy_arns = [aws_iam_policy.swnl_lambda_policy.arn]
}

data "archive_file" "dummy_code" {
  type        = "zip"
  output_path = "lambda_function_payload.zip"
  source {
    content  = "hello"
    filename = "dummy.txt"
  }
}

resource "aws_lambda_function" "swnl_lambda" {
  filename      = data.archive_file.dummy_code.output_path
  function_name = var.func_name
  role          = aws_iam_role.swnl_lambda_role.arn
  runtime       = "python3.12"
  handler       = "lambda_function.lambda_handler"
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.swnl_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.swnl_api.execution_arn}/*"
}