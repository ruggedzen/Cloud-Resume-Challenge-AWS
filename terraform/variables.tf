variable "domain_name" {
  default = "sheepwithnolegs.com"
  type    = string
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