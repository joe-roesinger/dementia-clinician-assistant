# Dementia Clinician Assistant

_This README will continue to grow as progress is complete. Right now its a heavy WIP_

**GOAL**

A clinician-facing AI agent for dementia workups and trial matching, built on GCP. Synthetic data only. Not for clinical use.


## Layout

```text
infra/
  bootstrap/    Terraform for the remote state bucket
```

## Prerequisites

- [Google Cloud CLI](https://cloud.google.com/sdk/docs/install)
- [Terraform](https://developer.hashicorp.com/terraform/install)
- A GCP billing account

## Setup

### 1. Create the project

One time setup.

```bash
gcloud auth login
gcloud auth application-default login

gcloud projects create <PROJECT_ID>
gcloud billing projects link <PROJECT_ID> --billing-account=<BILLING_ACCOUNT_ID>
gcloud config set project <PROJECT_ID>

# Some APIs require a quota project when called with user credentials
gcloud config set billing/quota_project <PROJECT_ID>
gcloud auth application-default set-quota-project <PROJECT_ID>

gcloud services enable billingbudgets.googleapis.com storage.googleapis.com
```

### 2. Set budget alert

_Note this will NOT stop the spending, that in the in roadmap_

```bash
gcloud billing budgets create \
  --billing-account=<BILLING_ACCOUNT_ID> \
  --display-name="DCA dev budget" \
  --budget-amount=25USD \
  --filter-projects=projects/<PROJECT_ID> \
  --threshold-rule=percent=0.5,basis=current-spend \
  --threshold-rule=percent=0.9,basis=current-spend \
  --threshold-rule=percent=1.0,basis=forecasted-spend
```

### 3. Create the bucket

Set `project` in `infra/bootstrap/terraform.tfvars` to your project ID.

// @??? How do enterprise organizations solve this problem
The bootstrap keeps its state in the bucket it creates, so the bucket has to exist before that backend works... bit of a chicken and the egg problem... For now comment out the `backend "gcs"` block in `infra/bootstrap/main.tf` for this first run. Terraform uses local state until step 4.
// ???@

```bash
cd infra/bootstrap
terraform init
terraform plan
terraform apply
```

### 4. Move the state into the bucket

Uncomment the `backend "gcs"` block and set `bucket` to `<PROJECT_ID>-tfstate`. Backend settings can't use variables, so the name is written out in full.

```bash
terraform init -migrate-state
gcloud storage ls gs://<PROJECT_ID>-tfstate/bootstrap/
terraform plan
rm -f terraform.tfstate terraform.tfstate.backup
```

The `ls` should list `default.tfstate`, and `plan` should report no changes.

To tear the bucket down later, move the state back to local first. Comment out the backend block again and run `terraform init -migrate-state`.

## Roadmap

- [x] Move bootstrap state into the bucket
- [ ] Dev environment in Terraform. FHIR store, Cloud Run service, IAM, budget
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
