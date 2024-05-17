terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.49.0"
    }
  }
  required_version = ">= 1.2.0"
}

#---Provider Conifg---#

provider "aws" {
  region  = "us-east-1"
  profile = "iamadmin-general"
}

#---Data---#

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

#---Resources---#

#Bucket Creation
resource "aws_s3_bucket" "swnl" {
  bucket = var.domain_name

  tags = {
    Project = "CRC"
  }

}

#Bucket Config
#Enable static website
resource "aws_s3_bucket_website_configuration" "swnl_site" {
  bucket = aws_s3_bucket.swnl.id

  index_document {
    suffix = "index.html"
  }
}
#Disable Public access protections
resource "aws_s3_bucket_public_access_block" "enable_pub_access" {
  bucket = aws_s3_bucket.swnl.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
#Apply bucket policy
resource "aws_s3_bucket_policy" "allow_read_all" {
  bucket = aws_s3_bucket.swnl.id
  policy = data.aws_iam_policy_document.allow_read_all.json
}


#R53 Zone
resource "aws_route53_zone" "swnl_zone" {
  name = var.domain_name
}

#Get cert from ACM for sheepwithnolegs.com
resource "aws_acm_certificate" "swnl_cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Project = "CRC"
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

#Change Registered domain NS to Hosted Zone NS
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

#CloudFront Distro
resource "aws_cloudfront_distribution" "swnl_cdn" {
  origin {
    domain_name = aws_s3_bucket.swnl.bucket_regional_domain_name
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

