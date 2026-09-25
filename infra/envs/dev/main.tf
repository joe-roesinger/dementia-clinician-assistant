terraform {
  required_version = "~> 1.16"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 8.4"
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

  impersonate_service_account = var.terraform_service_email
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
    "storage.googleapis.com",
  ]
}

resource "google_project_service" "apis" {
  for_each = toset(local.gcp_services)

  service = each.value

  disable_on_destroy = false
}

resource "google_healthcare_dataset" "dca" {
  name     = "dca"
  location = var.region
}

resource "google_healthcare_fhir_store" "fhir" {
  name                 = "fhir"
  version              = "R4"
  dataset              = google_healthcare_dataset.dca.id
  enable_update_create = true
}

resource "google_artifact_registry_repository" "images" {
  repository_id = "images"
  location      = var.region
  format        = "DOCKER"
  description   = "DCA ${var.region} Docker Image Repository"
}