variable "project" {
  type        = string
  description = "Project ID"
}

variable "region" {
  type        = string
  description = "Region to host in"
  default     = "us-central1"
}

variable "terraform_service_email" {
  type        = string
  description = "Service account email"
}