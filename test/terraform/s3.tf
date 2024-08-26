#Site Bucket Creation
resource "aws_s3_bucket" "swnl_buckets" {
  count         = length(var.bucket_names)
  bucket        = var.bucket_names[count.index]
  force_destroy = true
}

#Static Site Bucket Config
#Enable static website
resource "aws_s3_bucket_website_configuration" "swnl_site" {
  bucket = aws_s3_bucket.swnl_buckets[0].id

  index_document {
    suffix = "index.html"
  }
}
#Disable Public access protections
resource "aws_s3_bucket_public_access_block" "enable_pub_access" {
  bucket = aws_s3_bucket.swnl_buckets[0].id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
#Apply bucket policy
resource "aws_s3_bucket_policy" "allow_read_all" {
  bucket = aws_s3_bucket.swnl_buckets[0].id
  policy = data.aws_iam_policy_document.allow_read_all.json
}