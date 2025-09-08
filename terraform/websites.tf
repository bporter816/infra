data "aws_secretsmanager_secret_version" "website_secrets" {
  secret_id = "website-secrets"
}

locals {
  website_secrets = jsondecode(data.aws_secretsmanager_secret_version.website_secrets.secret_string)
  domain_map = merge([
    module.benjaminporter_me.default_domain_to_custom_domain,
    module.issilksongoutyet_com.default_domain_to_custom_domain,
  ]...)
}

module "benjaminporter_me" {
  source = "./modules/website"

  cloudflare_account_id       = var.cloudflare_account_id
  domain_name                 = "benjaminporter.me"
  pages_build_command         = "sh build.sh"
  pages_destination_dir       = "public"
  enable_www_to_apex_redirect = true
  auto_deploy                 = true
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
  enable_www_to_apex_redirect = true
  auto_deploy                 = false
  pages_environment_variables = {}
  pages_secrets               = {}
}

resource "cloudflare_list" "bulk_redirects" {
  account_id  = var.cloudflare_account_id
  name        = "website_custom_domain_redirects"
  description = "Redirects from pages.dev default domains to custom domains"
  kind        = "redirect"
}

resource "cloudflare_list_item" "bulk_redirects_item" {
  for_each = local.domain_map

  account_id = var.cloudflare_account_id
  list_id    = cloudflare_list.bulk_redirects.id

  redirect {
    source_url            = "${each.key}/"
    target_url            = "https://${each.value}"
    status_code           = 302
    preserve_query_string = true
    subpath_matching      = true
    preserve_path_suffix  = true
    include_subdomains    = true
  }
}

resource "cloudflare_ruleset" "bulk_redirects" {
  account_id = var.cloudflare_account_id

  phase = "http_request_redirect"
  kind  = "root"
  name  = "bulk_redirects"

  rules {
    action      = "redirect"
    description = "Redirects from pages.dev default domains to custom domains"
    expression  = format("http.request.full_uri in $%s", cloudflare_list.bulk_redirects.name)
    action_parameters {
      from_list {
        name = cloudflare_list.bulk_redirects.name
        key  = "http.request.full_uri"
      }
    }
  }
}
