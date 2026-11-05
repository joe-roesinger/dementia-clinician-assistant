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

variable "image_tag" {
  type        = string
  description = "Docker image tag for the agent service"
}

variable "model_id" {
  type        = string
  description = "Model ID to use with the agent service"
}