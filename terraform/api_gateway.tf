resource "aws_apigatewayv2_api" "swnl_api" {
  name          = "crc_api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "api_stage" {
  name        = "$default"
  api_id      = aws_apigatewayv2_api.swnl_api.id
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "lambda_api_integration" {
  api_id                 = aws_apigatewayv2_api.swnl_api.id
  integration_type       = "AWS_PROXY"
  payload_format_version = "2.0"

  integration_uri = aws_lambda_function.swnl_lambda.invoke_arn
}

resource "aws_apigatewayv2_route" "api_route" {
  api_id    = aws_apigatewayv2_api.swnl_api.id
  route_key = "GET /crc_lambda"

  target = "integrations/${aws_apigatewayv2_integration.lambda_api_integration.id}"
}