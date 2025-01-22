# benjaminporter.me
data "aws_secretsmanager_secret_version" "website_secrets" {
  secret_id = "website-secrets"
}

locals {
  website_secrets = jsondecode(data.aws_secretsmanager_secret_version.website_secrets.secret_string)
}

module "benjaminporter_me" {
  source = "./modules/website"

  cloudflare_account_id       = var.cloudflare_account_id
  domain_name                 = "benjaminporter.me"
  pages_build_command         = "sh build.sh"
  pages_destination_dir       = "public"
  enable_www_to_apex_redirect = true
  deploy_cron_schedule        = "0 0 * * *" # daily
  deploy_hook_url             = local.website_secrets["DEPLOY_HOOK_URL"]
  pages_environment_variables = {
    SPOTIFY_COUNT    = 3
    SPOTIFY_ENDPOINT = "playlist"
    STEAM_COUNT      = 3
  }
  pages_secrets = {
    SPOTIFY_CLIENT_ID     = local.website_secrets["SPOTIFY_CLIENT_ID"]
    SPOTIFY_CLIENT_SECRET = local.website_secrets["SPOTIFY_CLIENT_SECRET"]
    SPOTIFY_REFRESH_TOKEN = local.website_secrets["SPOTIFY_REFRESH_TOKEN"]
    SPOTIFY_PLAYLIST      = local.website_secrets["SPOTIFY_PLAYLIST"]
    STEAM_USER_ID         = local.website_secrets["STEAM_USER_ID"]
    STEAM_API_KEY         = local.website_secrets["STEAM_API_KEY"]
  }
}


module "issilksongoutyet_com" {
  source = "./modules/website"

  cloudflare_account_id       = var.cloudflare_account_id
  domain_name                 = "issilksongoutyet.com"
  pages_build_command         = "sh build.sh"
  pages_destination_dir       = "_site"
  enable_www_to_apex_redirect = true
  deploy_cron_schedule        = "0 * * * *" # hourly
  deploy_hook_url             = local.website_secrets["SILKSONG_DEPLOY_HOOK_URL"]
  pages_environment_variables = {}
  pages_secrets               = {}
}
