terraform {
  cloud {
    organization = "sheepwithnolegs"

    workspaces {
      name = "workspace-swnl-test"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.49.0"
    }
  }
  required_version = ">= 1.2.0"
}
#Provider Conifg Test Profile
provider "aws" {
  region  = var.aws_region
  profile = var.cli_profile[0]
  default_tags {
    tags = {
      env = "test"
    }
  }
}

#Provider Conifg Prod Profile
provider "aws" {
  alias   = "prod"
  region  = var.aws_region
  profile = var.cli_profile[1]
  default_tags {
    tags = {
      env = "test"
    }
  }
}
