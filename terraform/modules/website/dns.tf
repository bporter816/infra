resource "cloudflare_record" "apex" {
  zone_id = cloudflare_zone.zone.id
  type    = "CNAME"
  name    = "@"
  content = cloudflare_pages_project.pages.subdomain
  proxied = true
}

resource "cloudflare_record" "www" {
  count = var.enable_www_to_apex_redirect ? 1 : 0

  zone_id = cloudflare_zone.zone.id
  type    = "CNAME"
  name    = "www"
  content = cloudflare_pages_project.pages.subdomain
  comment = "Proxied for redirect to apex"
  proxied = true
}
