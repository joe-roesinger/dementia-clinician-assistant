variable "project" {}

variable "region" {
  default = "us-central1"
}

variable "terraform_admin" {
  type        = string
  description = "Email of of user that can impersonate terraform account."
}