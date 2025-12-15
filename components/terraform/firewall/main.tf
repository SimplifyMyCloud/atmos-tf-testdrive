terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Allow HTTP traffic from internet
resource "google_compute_firewall" "allow_http" {
  project = var.project_id
  name    = "${var.name_prefix}-allow-http"
  network = var.network_name

  description = "Allow HTTP traffic from internet"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]

  # Enable logging for verbose monitoring
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Allow SSH via Identity-Aware Proxy
resource "google_compute_firewall" "allow_iap_ssh" {
  project = var.project_id
  name    = "${var.name_prefix}-allow-iap-ssh"
  network = var.network_name

  description = "Allow SSH via Identity-Aware Proxy"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # GCP IAP IP range
  source_ranges = ["35.235.240.0/20"]

  # Enable logging for verbose monitoring
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}
