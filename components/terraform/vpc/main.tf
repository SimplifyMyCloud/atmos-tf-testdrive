terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Create VPC Network
resource "google_compute_network" "vpc" {
  project = var.project_id
  name    = var.network_name

  auto_create_subnetworks         = false
  routing_mode                    = var.routing_mode
  delete_default_routes_on_create = false

  description = var.description
}
