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
import {
  id = "2cb0221f06c8e9759fee84db2b6c1d9e"
  to = cloudflare_zone.issilksongoutyet_com
}

resource "cloudflare_zone" "issilksongoutyet_com" {
  account_id = var.cloudflare_account_id
  zone       = "issilksongoutyet.com"
  type       = "full"
  plan       = "free"
}

import {
  id = "2cb0221f06c8e9759fee84db2b6c1d9e/5c23a319147253d1dcf6e8a8f1c34a07"
  to = cloudflare_record.github_1
}

resource "cloudflare_record" "github_1" {
  zone_id = cloudflare_zone.issilksongoutyet_com.id
  type    = "A"
  name    = "@"
  content = "185.199.108.153"
  proxied = true
}

import {
  id = "2cb0221f06c8e9759fee84db2b6c1d9e/62e4631d3d8602665cf8deb7a5c558e1"
  to = cloudflare_record.github_2
}

resource "cloudflare_record" "github_2" {
  zone_id = cloudflare_zone.issilksongoutyet_com.id
  type    = "A"
  name    = "@"
  content = "185.199.109.153"
  proxied = true
}

import {
  id = "2cb0221f06c8e9759fee84db2b6c1d9e/59f16ec1f1f74ee8ed08b65114ec27b2"
  to = cloudflare_record.github_3
}

resource "cloudflare_record" "github_3" {
  zone_id = cloudflare_zone.issilksongoutyet_com.id
  type    = "A"
  name    = "@"
  content = "185.199.110.153"
  proxied = true
}

import {
  id = "2cb0221f06c8e9759fee84db2b6c1d9e/b028ef2ac434e790097005034283dc20"
  to = cloudflare_record.github_4
}

resource "cloudflare_record" "github_4" {
  zone_id = cloudflare_zone.issilksongoutyet_com.id
  type    = "A"
  name    = "@"
  content = "185.199.111.153"
  proxied = true
}

import {
  id = "2cb0221f06c8e9759fee84db2b6c1d9e/4b385b34f0974cb9105b053883ffe118"
  to = cloudflare_record.www
}

resource "cloudflare_record" "www" {
  zone_id = cloudflare_zone.issilksongoutyet_com.id
  type    = "CNAME"
  name    = "www"
  content = "bporter816.github.io"
  proxied = true
}
