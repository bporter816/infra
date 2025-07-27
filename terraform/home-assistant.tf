resource "random_password" "home_assistant_tunnel_secret" {
  length = 64
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "home_assistant" {
  account_id = var.cloudflare_account_id
  name       = "ha"
  secret     = base64sha256(random_password.home_assistant_tunnel_secret.result)
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "home_assistant" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.home_assistant.id

  config {
    ingress_rule {
      hostname = cloudflare_record.home_assistant.hostname
      service  = "http://${var.home_assistant_ip}:${var.home_assistant_port}"
    }

    ingress_rule {
      service = "http_status:404"
    }
  }
}

resource "cloudflare_record" "home_assistant" {
  zone_id = module.benjaminporter_me.cloudflare_zone_id
  type    = "CNAME"
  name    = "ha"
  content = cloudflare_zero_trust_tunnel_cloudflared.home_assistant.cname
  proxied = true
}

resource "cloudflare_ruleset" "home_assistant_rate_limit" {
  zone_id = module.benjaminporter_me.cloudflare_zone_id
  phase   = "http_ratelimit"
  kind    = "zone"
  name    = "ratelimits"

  rules {
    description = "ha-auth"
    expression  = <<-EOT
      http.host == "ha.benjaminporter.me" and starts_with(http.request.uri.path, "/auth/login_flow/")
    EOT
    action      = "block"
    ratelimit {
      characteristics = [
        "cf.colo.id",
        "ip.src",
      ]
      period              = 10
      requests_per_period = 1
      mitigation_timeout  = 10
    }
  }
}
