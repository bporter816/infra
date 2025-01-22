resource "cloudflare_ruleset" "redirects" {
  count = var.enable_www_to_apex_redirect ? 1 : 0

  zone_id = cloudflare_zone.zone.id
  phase   = "http_request_dynamic_redirect"
  kind    = "zone"
  name    = "redirects"

  rules {
    description = "Redirect www to apex"
    action      = "redirect"
    expression  = "(http.host eq \"www.${var.domain_name}\")"
    enabled     = true
    action_parameters {
      from_value {
        status_code = 302
        target_url {
          value = "https://${var.domain_name}"
        }
      }
    }
  }
}
