resource "cloudflare_record" "transiter" {
  zone_id = module.benjaminporter_me.cloudflare_zone_id
  type    = "CNAME"
  name    = "transiter.benjaminporter.me"
  content = "transiter-1540602530.us-east-1.elb.amazonaws.com"
  proxied = true
}
