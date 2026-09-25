# Dementia Clinician Assistant

_This README will continue to grow as progress is complete. Right now its a heavy WIP_

**GOAL**

A clinician-facing AI agent for dementia workups and trial matching, built on GCP. Synthetic data only. Not for clinical use.


## Layout

```text
infra/
  bootstrap/    State bucket, Terraform service account, billing budget
  envs/
    dev/        Dev environment via service account
```

## Prerequisites

- [Google Cloud CLI](https://cloud.google.com/sdk/docs/install)
- [Terraform](https://developer.hashicorp.com/terraform/install)
- A GCP billing account

## Setup

### 1. Create the project

```bash
gcloud auth login
gcloud auth application-default login

gcloud projects create <PROJECT_ID>
gcloud billing projects link <PROJECT_ID> --billing-account=<BILLING_ACCOUNT_ID>
gcloud config set project <PROJECT_ID>
gcloud config set billing/quota_project <PROJECT_ID>
gcloud auth application-default set-quota-project <PROJECT_ID>

gcloud services enable billingbudgets.googleapis.com storage.googleapis.com
```

### 2. Bootstrap

Creates the state bucket, the `terraform` service account, and a 25 USD budget alert.

Set `project`, `billing_account`, and `terraform_admin` in `infra/bootstrap/terraform.tfvars`. Comment out the `backend "gcs"` block in `infra/bootstrap/main.tf`.

```bash
cd infra/bootstrap
terraform init
terraform apply
```

Uncomment the `backend "gcs"` block and set `bucket` to `<PROJECT_ID>-tfstate`.

```bash
terraform init -migrate-state
rm -f terraform.tfstate terraform.tfstate.backup
```

### 3. Dev environment

Set `project` and `terraform_service_email` in `infra/envs/dev/terraform.tfvars`.

```bash
cd infra/envs/dev
terraform init \
  -backend-config="bucket=<PROJECT_ID>-tfstate" \
  -backend-config="impersonate_service_account=terraform@<PROJECT_ID>.iam.gserviceaccount.com"
terraform apply
```

## Roadmap

- [x] Move bootstrap state into the bucket
- [x] Dev environment with project APIs
- [x] Terraform service account with impersonation
- [x] Billing budget managed in Terraform
- [ ] FHIR store
- [ ] Artifact Registry and a Cloud Run service
- [ ] HARD stop on spending limits in GCP
- [ ] GitHub Actions with Workload Identity Federation
- [ ] Agent service with one FHIR tool
- [ ] Synthetic patient bundles
- [ ] Workup-gap agent
- [ ] Mock legacy referral system
- [ ] OpenTelemetry tracing by conversation ID
- [ ] Guideline retrieval
- [ ] Trial matching
- [ ] Citation critic
- [ ] Eval suite gating deploys in CI
