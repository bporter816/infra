resource "aws_ecs_cluster" "main" {
  name = "main"
}

resource "cloudflare_record" "rtr_validation" {
  zone_id = module.benjaminporter_me.cloudflare_zone_id
  type    = "CNAME"
  name    = "_8875065ac9745f376bbeb44a347d034b.transiter.benjaminporter.me."
  content = "_339915cc69d3e726030f9b061a614980.xlfgrmvvlj.acm-validations.aws."
}
