variable "domain_name" {
  default = "test.sheepwithnolegs.com"
  type    = string
}
variable "bucket_names" {
  default = ["test.sheepwithnolegs.com", "test.terraform-state-swnl"]
  type    = list(any)
}
variable "cli_profile" {
  default = ["swnl_test", "swnl_prod"]
  type    = list(any)
}
variable "aws_region" {
  default = "us-east-1"
  type    = string
}
variable "dyn_table" {
  default = "swnl_stats_test"
  type    = string
}
variable "func_name" {
  default = "crc_lambda_test"
  type    = string
}

