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

locals {
  terraform_service_account_roles = [
    "roles/serviceusage.serviceUsageAdmin",
    "roles/browser",
  ]
}

resource "google_service_account" "terraform" {
  account_id = "terraform"
}

resource "google_storage_bucket_iam_member" "tfstate_read_write" {
  bucket = google_storage_bucket.tfstate.name
  role   = "roles/storage.objectUser"
  member = google_service_account.terraform.member
}

resource "google_project_iam_member" "project_perms" {
  for_each = toset(local.terraform_service_account_roles)

  project = var.project
  role    = each.value
  member  = google_service_account.terraform.member
}

resource "google_service_account_iam_member" "terraform_impasta" {
  service_account_id = google_service_account.terraform.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "user:${var.terraform_admin}"
}
