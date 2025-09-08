resource "cloudflare_workers_script" "rebuild" {
  count = var.auto_deploy ? 1 : 0

  account_id = var.cloudflare_account_id
  name       = "rebuild-${local.pages_project_name}"
  module     = true
  content    = file("${path.module}/workers/rebuild-site.js")
}

resource "cloudflare_workers_cron_trigger" "rebuild_trigger" {
  count = var.auto_deploy ? 1 : 0

  account_id  = var.cloudflare_account_id
  script_name = cloudflare_workers_script.rebuild[0].name
  schedules = [
    var.deploy_cron_schedule,
  ]
}

resource "cloudflare_workers_secret" "deploy_hook_url" {
  count = var.auto_deploy ? 1 : 0

  account_id  = var.cloudflare_account_id
  name        = "DEPLOY_HOOK_URL"
  script_name = cloudflare_workers_script.rebuild[0].name
  secret_text = var.deploy_hook_url
}
