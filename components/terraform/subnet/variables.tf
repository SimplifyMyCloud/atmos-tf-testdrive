variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
}

variable "region" {
  description = "Region for the subnet"
  type        = string
}

variable "network_name" {
  description = "Name of the VPC network to create subnet in"
  type        = string
}

variable "ip_cidr_range" {
  description = "IP CIDR range for the subnet"
  type        = string
}

variable "private_ip_google_access" {
  description = "Enable private Google access"
  type        = bool
  default     = true
}

variable "description" {
  description = "Description of the subnet"
  type        = string
  default     = "Subnet managed by Terraform"
}

variable "flow_logs_interval" {
  description = "Flow logs aggregation interval"
  type        = string
  default     = "INTERVAL_5_SEC"
}

variable "flow_logs_sampling" {
  description = "Flow logs sampling rate"
  type        = number
  default     = 0.5
}

variable "flow_logs_metadata" {
  description = "Flow logs metadata to include"
  type        = string
  default     = "INCLUDE_ALL_METADATA"
}
