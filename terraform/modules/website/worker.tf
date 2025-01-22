resource "cloudflare_workers_script" "rebuild" {
  account_id = var.cloudflare_account_id
  name       = "rebuild-${local.pages_project_name}"
  module     = true
  content    = file("${path.module}/workers/rebuild-site.js")
}

resource "cloudflare_workers_cron_trigger" "rebuild_trigger" {
  account_id  = var.cloudflare_account_id
  script_name = cloudflare_workers_script.rebuild.name
  schedules = [
    var.deploy_cron_schedule,
  ]
}

resource "cloudflare_workers_secret" "deploy_hook_url" {
  account_id  = var.cloudflare_account_id
  name        = "DEPLOY_HOOK_URL"
  script_name = cloudflare_workers_script.rebuild.name
  secret_text = var.deploy_hook_url
}
