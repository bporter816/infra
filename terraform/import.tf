import {
  id = "${var.cloudflare_account_id}/1d3fd4f3-d5de-4192-94b1-eb714b67bdf8"
  to = cloudflare_zero_trust_tunnel_cloudflared.home_assistant
}

import {
  id = "${var.cloudflare_account_id}/1d3fd4f3-d5de-4192-94b1-eb714b67bdf8"
  to = cloudflare_zero_trust_tunnel_cloudflared_config.home_assistant
}

import {
  id = "${module.benjaminporter_me.cloudflare_zone_id}/64f82434ff1b811f521ed36285d7ecea"
  to = cloudflare_record.home_assistant
}

import {
  id = "zone/${module.benjaminporter_me.cloudflare_zone_id}/e2a23343152f4642b002b81077576d9c"
  to = cloudflare_ruleset.home_assistant_rate_limit
}
