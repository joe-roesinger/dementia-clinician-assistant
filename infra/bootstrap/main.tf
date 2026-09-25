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

  billing_project       = var.project
  user_project_override = true
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
    "roles/healthcare.datasetAdmin",
    "roles/healthcare.fhirStoreAdmin",
    "roles/artifactregistry.editor",
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

data "google_project" "this" {}

resource "google_billing_budget" "monthly_budget" {
  billing_account = "018F21-3E0136-6F72BD"
  display_name    = "Monthly DCA Dev Budget"
  amount {
    specified_amount {
      currency_code = "USD"
      units         = "25"
    }
  }

  budget_filter {
    projects = ["projects/${data.google_project.this.number}"]
  }

  threshold_rules {
    threshold_percent = 0.5
    spend_basis       = "CURRENT_SPEND"
  }

  threshold_rules {
    threshold_percent = 0.9
    spend_basis       = "CURRENT_SPEND"
  }

  threshold_rules {
    threshold_percent = 1.0
    spend_basis       = "FORECASTED_SPEND"
  }
}
