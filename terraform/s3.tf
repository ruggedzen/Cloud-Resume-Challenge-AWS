#Bucket Creation
resource "aws_s3_bucket" "swnl" {
  bucket = var.domain_name

  tags = local.common_tags

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