terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.49.0"
    }
  }
  required_version = ">= 1.2.0"
}
#Provider Conifg
provider "aws" {
  region  = var.aws_region
  profile = var.cli_profile
  default_tags {
    tags = {
      Project        = "CRC",
      awsApplication = "arn:aws:resource-groups:us-east-1:339713009188:group/SWNL_Site/08szscyi77nbk5dbine98hhr3b"
    }
  }
}