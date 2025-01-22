moved {
  from = cloudflare_zone.benjaminporter_me
  to   = module.benjaminporter_me.cloudflare_zone.zone
}

moved {
  from = cloudflare_zone.issilksongoutyet_com
  to   = module.issilksongoutyet_com.cloudflare_zone.zone
}

moved {
  from = cloudflare_record.apex
  to   = module.benjaminporter_me.cloudflare_record.apex
}

moved {
  from = cloudflare_record.issilksongoutyet_com_apex
  to   = module.issilksongoutyet_com.cloudflare_record.apex
}

moved {
  from = cloudflare_record.benjaminporter_me_www
  to   = module.benjaminporter_me.cloudflare_record.www[0]
}

moved {
  from = cloudflare_record.issilksongoutyet_com_www
  to   = module.issilksongoutyet_com.cloudflare_record.www[0]
}

moved {
  from = cloudflare_ruleset.benjaminporter_me_redirects
  to   = module.benjaminporter_me.cloudflare_ruleset.redirects[0]
}

moved {
  from = cloudflare_ruleset.issilksongoutyet_com_redirects
  to   = module.issilksongoutyet_com.cloudflare_ruleset.redirects[0]
}

moved {
  from = cloudflare_pages_project.benjaminporter_me
  to   = module.benjaminporter_me.cloudflare_pages_project.pages
}

moved {
  from = cloudflare_pages_project.issilksongoutyet_com
  to   = module.issilksongoutyet_com.cloudflare_pages_project.pages
}

moved {
  from = cloudflare_pages_domain.benjaminporter_me_domain
  to   = module.benjaminporter_me.cloudflare_pages_domain.custom_domain
}

moved {
  from = cloudflare_pages_domain.issilksongoutyet_com_domain
  to   = module.issilksongoutyet_com.cloudflare_pages_domain.custom_domain
}

moved {
  from = cloudflare_workers_script.rebuild
  to   = module.benjaminporter_me.cloudflare_workers_script.rebuild
}

moved {
  from = cloudflare_workers_script.issilksongoutyet_com_rebuild
  to   = module.issilksongoutyet_com.cloudflare_workers_script.rebuild
}

moved {
  from = cloudflare_workers_cron_trigger.rebuild_trigger
  to   = module.benjaminporter_me.cloudflare_workers_cron_trigger.rebuild_trigger
}

moved {
  from = cloudflare_workers_cron_trigger.issilksongoutyet_com_rebuild_trigger
  to   = module.issilksongoutyet_com.cloudflare_workers_cron_trigger.rebuild_trigger
}

moved {
  from = cloudflare_workers_secret.deploy_hook_url
  to   = module.benjaminporter_me.cloudflare_workers_secret.deploy_hook_url
}

moved {
  from = cloudflare_workers_secret.issilksongoutyet_com_deploy_hook_url
  to   = module.issilksongoutyet_com.cloudflare_workers_secret.deploy_hook_url
}
