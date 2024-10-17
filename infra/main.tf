terraform {
  required_version = "1.9.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.65.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-backend-20230207141844477000000001"
    key            = "dataexfiltration/main/tfstate-eu-central"
    region         = "eu-south-1"
    dynamodb_table = "terraform-lock"
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = var.tags
  }
}

resource "random_id" "unique" {
  byte_length = 3
}

locals {
  project = "${var.prefix}-${random_id.unique.hex}"
}

data "aws_availability_zones" "available" {
  state = "available"
}

output "project" {
  value = local.project
}
