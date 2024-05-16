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
  bucket = "sheepwithnolegs.com"

  tags = {
    Project = "CRC"
  }

}

#Bucket Config
#Enable static website
resource "aws_s3_bucket_website_configuration" "sheepwithnolegs_site" {
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
resource "aws_route53_zone" "primary" {
  name = "sheepwithnolegs.com"
}

#TODO: Get Digital cert from ACM for sheepwithnolegs.com
resource "aws_acm_certificate" "swnl_cert" {
  domain_name = "sheepwithnolegs.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Project = "CRC"
  } 
}
#TODO: DNS Cert auth
resource "aws_route53_record" "swnl_cert_auth" {
  name = aws_acm_certificate.swnl_cert.validation_method
  
}

#TODO: A record for CloudFront distro
#TODO: Change NS in GoDaddy with R53 NS
#TODO: CloudFront Distro

