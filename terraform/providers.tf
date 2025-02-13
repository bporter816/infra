terraform {
  cloud {
    organization = "bporter816"
    workspaces {
      name = "infra"
    }
  }
  required_version = "~> 1.10.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.86.1"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.52.0"
    }
  }
}
