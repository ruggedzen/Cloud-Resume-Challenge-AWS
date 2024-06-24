#R53 Zone
resource "aws_route53_zone" "swnl_zone" {
  name = var.domain_name
}

#Get cert from ACM for root domain
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
  zone_id         = aws_route53_zone.swnl_zone.zone_id
}

#Change registered domain NS to Hosted Zone NS | Domain will be moved to prod
resource "aws_route53domains_registered_domain" "swnl_ns" {
  domain_name = var.domain_name

  dynamic "name_server" {
    for_each = toset(aws_route53_zone.swnl_zone.name_servers)
    content {
      name = name_server.value
    }
  }
}


#Validate ACM Cert
resource "aws_acm_certificate_validation" "swnl_cert_val" {
  certificate_arn         = aws_acm_certificate.swnl_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.swnl_cert_cname : record.fqdn]
}

#A record for CloudFront distro 
resource "aws_route53_record" "swnl_cf_alias" {
  zone_id = aws_route53_zone.swnl_zone.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.swnl_cdn.domain_name
    zone_id                = aws_cloudfront_distribution.swnl_cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

