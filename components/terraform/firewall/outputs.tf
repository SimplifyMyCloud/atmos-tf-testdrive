output "allow_http_rule_id" {
  description = "The ID of the HTTP firewall rule"
  value       = google_compute_firewall.allow_http.id
}

output "allow_iap_ssh_rule_id" {
  description = "The ID of the IAP SSH firewall rule"
  value       = google_compute_firewall.allow_iap_ssh.id
}

output "allow_http_rule_name" {
  description = "The name of the HTTP firewall rule"
  value       = google_compute_firewall.allow_http.name
}

output "allow_iap_ssh_rule_name" {
  description = "The name of the IAP SSH firewall rule"
  value       = google_compute_firewall.allow_iap_ssh.name
}
