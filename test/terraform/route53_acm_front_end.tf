#R53 Test Zone
resource "aws_route53_zone" "test_swnl_zone" {
  name = var.domain_name
}
#R53 Prod Zone
data "aws_route53_zone" "prod_swnl_zone" {
  provider     = aws.prod
  name         = "sheepwithnolegs.com."
  private_zone = false
}

#Create NS Record for Test NS in Prod R53
resource "aws_route53_record" "prod_ns_record" {
  provider = aws.prod

  zone_id = data.aws_route53_zone.prod_swnl_zone.zone_id
  name    = var.domain_name
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.test_swnl_zone.name_servers

  depends_on = [aws_route53_zone.test_swnl_zone]
}

#Get cert from ACM for test domain
resource "aws_acm_certificate" "swnl_cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

#Create CNAME to auth ACM provided cert
resource "aws_route53_record" "swnl_cert_cname" {
  for_each = {
    for dvo in aws_acm_certificate.swnl_cert.domain_validation_options : dvo.domain_name => {
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
resource "aws_acm_certificate_validation" "swnl_cert_val" {
  certificate_arn         = aws_acm_certificate.swnl_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.swnl_cert_cname : record.fqdn]

  depends_on = [aws_route53_record.prod_ns_record]
}

#A record for CloudFront distro 
resource "aws_route53_record" "swnl_cf_alias" {
  zone_id = aws_route53_zone.test_swnl_zone.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.swnl_cdn.domain_name
    zone_id                = aws_cloudfront_distribution.swnl_cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

