---
status: proposed
date: 2026-10-06
---

# ADR-001: Environments and Terraform root module layout

## Context

This project has a 25 USD budget, one GCP project, and me :). All of the infrastructure is built with Terraform. I want the number of environments and first Terraform configurations settled before adding more resources.

One chick v egg problem shaped the layout early. Terraform needs a state bucket and a service account before it can manage anything else, so something outside the environment has to create them.

## Options

### How many environments

**Dev only.** One project, one copy of everything.

**Dev and prod.** A second environment needs a second GCP project and a second copy of every resource. It doubles what I have to watch for cost and tear down in an idle week, and nobody would use it in the development phase.

### How environments are separated

**A directory per environment.** `infra/envs/dev` and `infra/envs/prod` are each a root module with a state prefix of their own. The file tree shows which environment a change touches. Environments can differ on purpose. The cost is duplication between the directories until shared pieces move into modules.

**Terraform workspaces.** One directory and one backend, with a state per workspace. There's less to copy, but the active workspace is invisible in the code, so it's easy to apply to the wrong one. The [Terraform docs](https://developer.hashicorp.com/terraform/cli/workspaces) say workspaces don't fit deployments that need separate credentials and access controls, and dev and prod would.

**One root module with a `.tfvars` file per environment.** The environment is picked by flags at `init` and `apply`. A wrong flag pairs one environment's variables with another's state. Any real difference between environments turns into conditionals.

### When to write modules

**Up front.** Build atomic units of code and call them from dev. Do one thing and do it well.

**On the second caller.** Keep resources inline until something needs the same shape twice, then extract.

## Decision

One environment, dev.

Each environment is a directory under `infra/envs/`, a root module with its own state prefix in the shared bucket. Prod would be `infra/envs/prod`.

Bootstrap stays a separate root module. I run it as myself, and it creates the state bucket, the `terraform` service account, and the budget. Dev runs as that service account through impersonation.

```text
infra/
  bootstrap/    runs as me                          | state prefix bootstrap
  envs/
    dev/        runs as the terraform SA            | state prefix envs/dev
  modules/
```

Modules get written on the second caller. The first one I expect is a Cloud Run service module in M2, when `referral-legacy` joins `agent-service`.

## Consequences

- Adding prod means a new directory and a new GCP project. Until modules exist, that directory starts as a copy of dev.
- Bootstrap assumes one project today. The bucket name is fixed in its backend block and the billing account ID is fixed in the budget resource. Prod would need a bootstrap run of its own, with those two values passed in.
- `infra/envs/dev/main.tf` keeps growing until module extraction. That's fine for a few weeks.
- Permissions for the `terraform` service account change only in bootstrap, which I run by hand. Dev can't raise its own project roles. I think this is fine?
- An empty project takes two applies to stand up, bootstrap and then dev. Unsure how I would get around this at the moment.
