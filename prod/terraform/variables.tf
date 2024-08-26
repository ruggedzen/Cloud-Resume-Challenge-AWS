variable "domain_name" {
  default = "sheepwithnolegs.com"
  type    = string
}
variable "bucket_names" {
  default = ["sheepwithnolegs.com", "terraform-state-swnl"]
  type    = list(any)
}
variable "cli_profile" {
  default = "swnl_prod"
  type    = string
}
variable "aws_region" {
  default = "us-east-1"
  type    = string
}
variable "dyn_table" {
  default = "swnl_stats"
  type    = string
}
variable "func_name" {
  default = "crc_lambda"
  type    = string
}
variable "app_tag" {
  default = "arn:aws:resource-groups:us-east-1:339713009188:group/SWNL_Site/08szscyi77nbk5dbine98hhr3b"
  type    = string
}
