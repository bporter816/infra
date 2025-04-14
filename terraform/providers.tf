terraform {
  cloud {
    organization = "bporter816"
    workspaces {
      name = "infra"
    }
  }
  required_version = "~> 1.11.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.94.1"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.52.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}
