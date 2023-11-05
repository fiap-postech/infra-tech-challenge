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

    mysql = {
      source  = "bluemill/mysql"
      version = "1.11.0"
    }
  }
}