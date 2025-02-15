locals {
  pages_project_name = replace(var.domain_name, ".", "-")
}

resource "cloudflare_pages_project" "pages" {
  account_id        = var.cloudflare_account_id
  production_branch = "main"
  name              = local.pages_project_name

  source {
    type = "github"
    config {
      owner             = "bporter816"
      repo_name         = var.domain_name
      production_branch = "main"
    }
  }

  build_config {
    build_command   = var.pages_build_command
    destination_dir = var.pages_destination_dir
    build_caching   = true
  }

  deployment_configs {
    production {
      environment_variables = var.pages_environment_variables
      secrets               = var.pages_secrets
      fail_open             = true
      usage_model           = "standard"
    }
  }
}

resource "cloudflare_pages_domain" "custom_domain" {
  account_id   = var.cloudflare_account_id
  project_name = cloudflare_pages_project.pages.name
  domain       = var.domain_name
}
