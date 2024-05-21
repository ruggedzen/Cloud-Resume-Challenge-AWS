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
}

provider "aws" {
  alias   = "dns"
  region  = var.aws_region
  profile = "iamadmin-general"
}