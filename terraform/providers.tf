terraform {
  cloud {
    organization = "bporter816"
    workspaces {
      name = "infra"
    }
  }
  required_version = "~> 1.10.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.82.2"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.49.1"
    }
  }
}
