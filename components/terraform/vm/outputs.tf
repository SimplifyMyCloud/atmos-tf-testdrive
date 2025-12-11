output "instance_id" {
  description = "The ID of the VM instance"
  value       = google_compute_instance.vm.instance_id
}

output "instance_name" {
  description = "The name of the VM instance"
  value       = google_compute_instance.vm.name
}

output "instance_self_link" {
  description = "The self-link of the VM instance"
  value       = google_compute_instance.vm.self_link
}

output "internal_ip" {
  description = "Internal IP address of the VM"
  value       = google_compute_instance.vm.network_interface[0].network_ip
}

output "external_ip" {
  description = "External IP address of the VM"
  value       = try(google_compute_instance.vm.network_interface[0].access_config[0].nat_ip, "")
}

output "zone" {
  description = "Zone where the VM is deployed"
  value       = google_compute_instance.vm.zone
}
