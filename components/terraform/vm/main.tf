terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Create GCE VM Instance
resource "google_compute_instance" "vm" {
  project      = var.project_id
  name         = var.instance_name
  zone         = var.zone
  machine_type = var.machine_type

  tags = var.network_tags

  boot_disk {
    initialize_params {
      image = var.boot_disk_image
      size  = var.boot_disk_size
      type  = var.boot_disk_type
    }
  }

  network_interface {
    network    = var.network_name
    subnetwork = var.subnet_name

    # Assign external IP for internet access
    access_config {
      network_tier = "STANDARD"
    }
  }

  # Metadata startup script
  metadata = {
    startup-script = var.startup_script
  }

  # Service account with necessary scopes
  service_account {
    email  = var.service_account_email
    scopes = var.service_account_scopes
  }

  # Enable verbose logging
  enable_display = false

  labels = var.labels
}
