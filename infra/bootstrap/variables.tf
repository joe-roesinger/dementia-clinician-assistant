variable "project" {
  type = string
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "terraform_admin" {
  type        = string
  description = "Email of of user that can impersonate terraform account."
}

variable "billing_account" {
  type        = string
  description = "Billing account ID"
}