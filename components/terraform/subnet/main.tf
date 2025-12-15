terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Create Subnet
resource "google_compute_subnetwork" "subnet" {
  project = var.project_id
  name    = var.subnet_name
  region  = var.region

  network       = var.network_name
  ip_cidr_range = var.ip_cidr_range

  private_ip_google_access = var.private_ip_google_access

  description = var.description

  # Enable flow logs for verbose logging
  log_config {
    aggregation_interval = var.flow_logs_interval
    flow_sampling        = var.flow_logs_sampling
    metadata             = var.flow_logs_metadata
  }
}
