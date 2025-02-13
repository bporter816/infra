output "default_domain_to_custom_domain" {
  description = "Map of pages.dev domain to custom domain for use in bulk redirects"
  value = {
    (cloudflare_pages_project.pages.subdomain) = var.domain_name
  }
}
