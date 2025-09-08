variable "domain_name" {
  type = string
}

variable "auto_deploy" {
  type = bool
}

variable "deploy_cron_schedule" {
  type    = string
  default = null
}

variable "deploy_hook_url" {
  type      = string
  sensitive = true
  default   = null
}

variable "enable_www_to_apex_redirect" {
  type = bool
}

variable "cloudflare_account_id" {
  type = string
}

variable "pages_build_command" {
  type    = string
  default = null
}

variable "pages_destination_dir" {
  type    = string
  default = null
}

variable "pages_environment_variables" {
  type = map(any)
}

variable "pages_secrets" {
  type      = map(string)
  sensitive = true
}
