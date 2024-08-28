resource "aws_apigatewayv2_api" "swnl_api" {
  name          = "crc_api_test"
  protocol_type = "HTTP"
}

#Default stage
resource "aws_apigatewayv2_stage" "api_stage" {
  name        = "$default"
  api_id      = aws_apigatewayv2_api.swnl_api.id
  auto_deploy = true
}
#Lambda integration
resource "aws_apigatewayv2_integration" "lambda_api_integration" {
  api_id                 = aws_apigatewayv2_api.swnl_api.id
  integration_type       = "AWS_PROXY"
  payload_format_version = "2.0"

  integration_uri = aws_lambda_function.swnl_lambda.invoke_arn
}
#GET route to Lambda
resource "aws_apigatewayv2_route" "api_route" {
  api_id    = aws_apigatewayv2_api.swnl_api.id
  route_key = "GET /crc_lambda_test"

  target = "integrations/${aws_apigatewayv2_integration.lambda_api_integration.id}"
}


#Get cert from ACM API Sub Domain
resource "aws_acm_certificate" "swnl_api_cert" {
  domain_name       = "api.${var.domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

#Create CNAME to auth ACM provided cert
resource "aws_route53_record" "swnl_api_cert_cname" {
  for_each = {
    for dvo in aws_acm_certificate.swnl_api_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.test_swnl_zone.zone_id
}

#Validate ACM Cert
resource "aws_acm_certificate_validation" "swnl_api_cert_val" {
  certificate_arn         = aws_acm_certificate.swnl_api_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.swnl_api_cert_cname : record.fqdn]

  depends_on = [aws_route53_record.swnl_api_cert_cname]
}

#Create Custom API domain
resource "aws_apigatewayv2_domain_name" "api_test_domain" {
  domain_name = "api.${var.domain_name}"

  domain_name_configuration {
    certificate_arn = aws_acm_certificate.swnl_api_cert.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

#Create API A Record
resource "aws_route53_record" "api_test_domain_record" {
  name    = aws_apigatewayv2_domain_name.api_test_domain.domain_name
  type    = "A"
  zone_id = aws_route53_zone.test_swnl_zone.zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.api_test_domain.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.api_test_domain.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

#Map Custom Domain to API
resource "aws_apigatewayv2_api_mapping" "name" {
  api_id      = aws_apigatewayv2_api.swnl_api.id
  stage       = aws_apigatewayv2_stage.api_stage.id
  domain_name = aws_apigatewayv2_domain_name.api_test_domain.id
}