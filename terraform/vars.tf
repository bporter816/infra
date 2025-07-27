variable "cloudflare_account_id" {
  type        = string
  description = "Cloudflare account ID"
}

variable "rtr_caddy_ingress_port" {
  type    = number
  default = 8090
}

variable "rtr_transiter_ingress_port" {
  type    = number
  default = 8080
}

variable "home_assistant_ip" {
  type = string
}

variable "home_assistant_port" {
  type    = number
  default = 8123
}
