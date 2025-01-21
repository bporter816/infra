# benjaminporter.me
data "aws_secretsmanager_secret_version" "website_secrets" {
  secret_id = "website-secrets"
}

locals {
  website_secrets = jsondecode(data.aws_secretsmanager_secret_version.website_secrets.secret_string)
}

resource "cloudflare_zone" "benjaminporter_me" {
  account_id = var.cloudflare_account_id
  zone       = "benjaminporter.me"
  type       = "full"
  plan       = "free"
}

resource "cloudflare_pages_project" "benjaminporter_me" {
  account_id        = var.cloudflare_account_id
  production_branch = "main"
  name              = "benjaminporter-me"

  source {
    type = "github"
    config {
      owner             = "bporter816"
      repo_name         = "benjaminporter.me"
      production_branch = "main"
    }
  }

  build_config {
    build_command   = "sh build.sh"
    destination_dir = "public"
    build_caching   = false
  }

  deployment_configs {
    production {
      environment_variables = {
        SPOTIFY_COUNT    = 3
        SPOTIFY_ENDPOINT = "playlist"
        STEAM_COUNT      = 3

      }
      secrets = {
        SPOTIFY_CLIENT_ID     = local.website_secrets["SPOTIFY_CLIENT_ID"]
        SPOTIFY_CLIENT_SECRET = local.website_secrets["SPOTIFY_CLIENT_SECRET"]
        SPOTIFY_REFRESH_TOKEN = local.website_secrets["SPOTIFY_REFRESH_TOKEN"]
        SPOTIFY_PLAYLIST      = local.website_secrets["SPOTIFY_PLAYLIST"]
        STEAM_USER_ID         = local.website_secrets["STEAM_USER_ID"]
        STEAM_API_KEY         = local.website_secrets["STEAM_API_KEY"]
      }
      fail_open   = true
      usage_model = "standard"
    }
  }
}

resource "cloudflare_pages_domain" "benjaminporter_me_domain" {
  account_id   = var.cloudflare_account_id
  project_name = "benjaminporter-me"
  domain       = "benjaminporter.me"
}

resource "cloudflare_record" "apex" {
  zone_id = cloudflare_zone.benjaminporter_me.id
  type    = "CNAME"
  name    = "@"
  content = "benjaminporter-me.pages.dev"
  proxied = true
}

resource "cloudflare_workers_script" "rebuild" {
  account_id = var.cloudflare_account_id
  name       = "rebuild-site"
  module     = true
  content    = file("workers/rebuild-site.js")
}

resource "cloudflare_workers_cron_trigger" "rebuild_trigger" {
  account_id  = var.cloudflare_account_id
  script_name = cloudflare_workers_script.rebuild.name
  schedules = [
    "0 0 * * *", # daily at midnight
  ]
}

resource "cloudflare_workers_secret" "deploy_hook_url" {
  account_id  = var.cloudflare_account_id
  name        = "DEPLOY_HOOK_URL"
  script_name = cloudflare_workers_script.rebuild.name
  secret_text = local.website_secrets["DEPLOY_HOOK_URL"]
}

# issilksongoutyet.com
resource "cloudflare_zone" "issilksongoutyet_com" {
  account_id = var.cloudflare_account_id
  zone       = "issilksongoutyet.com"
  type       = "full"
  plan       = "free"
}

resource "cloudflare_pages_project" "issilksongoutyet_com" {
  account_id        = var.cloudflare_account_id
  production_branch = "main"
  name              = "issilksongoutyet-com"

  source {
    type = "github"
    config {
      owner             = "bporter816"
      repo_name         = "issilksongoutyet.com"
      production_branch = "main"
    }
  }

  build_config {
    build_command   = "sh build.sh"
    destination_dir = "_site"
    build_caching   = false
  }
}

resource "cloudflare_pages_domain" "issilksongoutyet_com_domain" {
  account_id   = var.cloudflare_account_id
  project_name = "issilksongoutyet-com"
  domain       = "issilksongoutyet.com"
}

resource "cloudflare_record" "issilksongoutyet_com_apex" {
  zone_id = cloudflare_zone.issilksongoutyet_com.id
  type    = "CNAME"
  name    = "@"
  content = "issilksongoutyet-com.pages.dev"
  proxied = true
}

resource "cloudflare_workers_script" "issilksongoutyet_com_rebuild" {
  account_id = var.cloudflare_account_id
  name       = "rebuild-site"
  module     = true
  content    = file("workers/rebuild-site.js")
}

resource "cloudflare_workers_cron_trigger" "issilksongoutyet_com_rebuild_trigger" {
  account_id  = var.cloudflare_account_id
  script_name = cloudflare_workers_script.rebuild.name
  schedules = [
    "0 * * * *", # hourly
  ]
}

resource "cloudflare_workers_secret" "issilksongoutyet_com_deploy_hook_url" {
  account_id  = var.cloudflare_account_id
  name        = "DEPLOY_HOOK_URL"
  script_name = cloudflare_workers_script.rebuild.name
  secret_text = local.website_secrets["SILKSONG_DEPLOY_HOOK_URL"]
}
