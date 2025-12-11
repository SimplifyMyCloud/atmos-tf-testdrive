variable "project_name" {
  description = "The display name of the project"
  type        = string
}

variable "project_id" {
  description = "The project ID. Must be unique across GCP"
  type        = string
}

variable "org_id" {
  description = "The organization ID"
  type        = string
}

variable "billing_account" {
  description = "The billing account ID"
  type        = string
}

variable "labels" {
  description = "Labels to apply to the project"
  type        = map(string)
  default     = {}
}

variable "enabled_apis" {
  description = "List of APIs to enable for the project"
  type        = list(string)
  default = [
    "compute.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
  ]
}
