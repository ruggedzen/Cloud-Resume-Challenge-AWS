resource "aws_dynamodb_table" "swnl_stats_table" {
  name         = var.dyn_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "metric"

  attribute {
    name = "metric"
    type = "S"
  }
}