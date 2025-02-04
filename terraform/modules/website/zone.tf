resource "cloudflare_zone" "zone" {
  account_id = var.cloudflare_account_id
  zone       = var.domain_name
  type       = "full"
  plan       = "free"
}

resource "cloudflare_zone_settings_override" "settings" {
  zone_id = cloudflare_zone.zone.id

  settings {
    always_use_https         = "on"
    automatic_https_rewrites = "on"
  }
}
