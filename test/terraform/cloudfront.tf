#CloudFront Distro
resource "aws_cloudfront_distribution" "swnl_cdn" {
  origin {
    domain_name = aws_s3_bucket.swnl_buckets[0].bucket_regional_domain_name
    origin_id   = var.domain_name
  }

  enabled             = true
  default_root_object = "index.html"

  aliases = [var.domain_name]

  default_cache_behavior {
    # Using the CachingOptomised managed policy ID:
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = var.domain_name
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  price_class = "PriceClass_100"

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.swnl_cert_val.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  depends_on = [
    aws_acm_certificate.swnl_cert
  ]
}

resource "aws_cloudfront_origin_access_control" "test_swnl_oac" {
  name                              = "test_swnl_oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}