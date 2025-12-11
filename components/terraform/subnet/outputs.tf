output "subnet_id" {
  description = "The ID of the subnet"
  value       = google_compute_subnetwork.subnet.id
}

output "subnet_name" {
  description = "The name of the subnet"
  value       = google_compute_subnetwork.subnet.name
}

output "subnet_self_link" {
  description = "The self-link of the subnet"
  value       = google_compute_subnetwork.subnet.self_link
}

output "ip_cidr_range" {
  description = "The IP CIDR range of the subnet"
  value       = google_compute_subnetwork.subnet.ip_cidr_range
}

output "gateway_address" {
  description = "The gateway address for the subnet"
  value       = google_compute_subnetwork.subnet.gateway_address
}
