terraform {
  required_version = ">= 1.0.0"

  cloud {
    organization = "fiap-pos-tech"

    workspaces {
      name = "tech-challenge"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.56.0"
    }
  }
}

provider "aws" {
  region              = "us-east-1"
  allowed_account_ids = ["212517236385"]

  default_tags {
    tags = {
      "worload" = "tech-challenge"
    }
  }
}