terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Create GCP Project
resource "google_project" "project" {
  name            = var.project_name
  project_id      = var.project_id
  org_id          = var.org_id
  billing_account = var.billing_account

  labels = var.labels

  auto_create_network = false
}

# Enable required APIs
resource "google_project_service" "apis" {
  for_each = toset(var.enabled_apis)

  project = google_project.project.project_id
  service = each.value

  disable_on_destroy = false
}
