terraform {
  required_version = "~> 1.16"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "8.4"
    }
  }

  backend "gcs" {
    prefix = "envs/dev"
  }
}

provider "google" {
  project = var.project
  region  = var.region
  default_labels = {
    app = "dca"
    env = "dev"
  }
}

locals {
  gcp_services = [
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "healthcare.googleapis.com",
    "aiplatform.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "billingbudgets.googleapis.com",
    "storage.googleapis.com"
  ]
}

resource "google_project_service" "apis" {
  for_each = toset(local.gcp_services)

  service = each.value

  disable_on_destroy = false
}