resource "aws_ecs_cluster" "main" {
  name = "main"
}

resource "cloudflare_record" "rtr_validation" {
  zone_id = module.benjaminporter_me.cloudflare_zone_id
  type    = "CNAME"
  name    = "_ff50614463ea5991afcb3199f9efc2b6.benjaminporter.me"
  content = "_b44f2b810192bb92d37cfa345d4786ef.zzssrbpcnq.acm-validations.aws."
}
