terraform {
  required_version = "~> 1.16"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 8.4"
    }
  }

  backend "gcs" {
    bucket = "dca-dev-joe-roesinger-tfstate"
    prefix = "bootstrap"
  }
}

provider "google" {
  project = var.project
  region  = var.region
}

resource "google_storage_bucket" "tfstate" {
  name     = "${var.project}-tfstate"
  location = var.region
  project  = var.project

  versioning {
    enabled = true
  }

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = false

  lifecycle {
    prevent_destroy = true
  }

  lifecycle_rule {
    condition {
      num_newer_versions = 10
    }

    action {
      type = "Delete"
    }
  }
}