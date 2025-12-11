variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for firewall rule names"
  type        = string
  default     = "fw"
}
