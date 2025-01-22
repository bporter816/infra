resource "cloudflare_zone" "zone" {
  account_id = var.cloudflare_account_id
  zone       = var.domain_name
  type       = "full"
  plan       = "free"
}
