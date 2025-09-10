## Azure Key Vault + Terraform + Remote State (Blob) + GitHub Actions (plan → manual apply)

Minimal, production‑style setup: Resource Group + Key Vault (RBAC) + Secret, with remote state in Azure Blob and a two‑stage CI (plan on push/PR, manual apply with approval).

Project Overview

This repository provisions a small Azure footprint using Terraform and validates it in CI. The pipeline runs in two stages:

**Terraform – plan (push/PR)**

- Creates/maintains Resource Group kv-secrets-rg (region West Europe)

- Creates Azure Key Vault with RBAC enabled

- Manages a secret db-password (value comes from Terraform variable)

- Uses remote state in Azure Blob Storage (tfstate-rg / tfstate78234926512 / container tfstate / key kv-secrets/dev/terraform.tfstate)

- Uploads the compiled tfplan as a workflow artifact

**Terraform – manual apply (workflow_dispatch)**

- Downloads the tfplan artifact

- Runs terraform apply tfpla

**Result:** reproducible RG + Key Vault + Secret, with controlled access via Azure RBAC and a clean CI flow.

### Requirements

- Azure subscription with permission to create RG and KV

- Existing Storage Account and container for Terraform state (we use: tfstate-rg / tfstate78234926512 / tfstate)

- GitHub repository with OIDC to Azure (App Registration + Federated Credential)

**Repository Structure**

```
.
├─ main.tf 
├─ outputs.tf
├─ locals.tf
├─ providers.tf
├─ variables.tf           
├─ outputs.tf            
├─ README.md
├─ .gitignore
├─ terraform.tfvars.example   
└─ .github/
   └─ workflows/
      └─ terraform-plan.yml     # plan (tfplan artifact) + manual apply with approval

```

### Variables

Match your variables.tf.

| Name | Description |
|-----------|-----------|
| sub_id | Azure Subscription ID |
| rg_name | kv-secrets-rg |
| location | West Europe |
| db_password | SENSITIVE – value for KV secret |

—

`db_password` is marked `sensitive = true` – it won’t be printed in outputs or logs.

**Backend (remote state)**

The backend is configured in code (literals only):


```
terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstate78234926512"
    container_name       = "tfstate"
    key                  = "kv-secrets/dev/terraform.tfstate"
    use_azuread_auth     = true
  }
}

```

First migration from local to remote:
```
terraform init -migrate-state
```
The container must exist. Terraform will create the blob at key automatically if it has permissions.

**Azure RBAC (must‑read)**

Grant the following roles to the Service Principal used by GitHub Actions (the OIDC App Registration’s Service Principal):

**Remote state**

Storage Blob Data Contributor on the Storage Account or on the tfstate** container**

**Key Vault**

- For plan (read): **Key Vault Secrets User**

- For apply (write): **Key Vault Secrets Officer**

**Remember:** grant appropriate permissions on Key Vault and on the remote backend for the Service Principal, otherwise you’ll hit 403s (ForbiddenByRbac / AuthorizationPermissionMismatch).

### GitHub Variables & Secrets

Set under **Settings → Secrets and variables → Actions**.

### Variables (non‑secret)

- `AZURE_SUBSCRIPTION_ID` – your Subscription ID

- `AZURE_TENANT_ID` – Entra ID tenant

- `AZURE_CLIENT_ID` – App Registration (client) ID used by OIDC login

**Secrets (secret)**

- `DB_PASSWORD` – value mapped to `TF_VAR_db_password`

Terraform variables in CI are passed via environment variables named `TF_VAR_<name>` (e.g., `TF_VAR_db_password`).

Workflows

`./.github/workflows/terraform-ci.yml`

**On push / pull_request** → runs plan:

- `terraform fmt -check, validate`

- `terraform init -reconfigure`

- `terraform plan -out tfplan`

- Uploads tfplan as an artifact

**On workflow_dispatch → plan** + apply in one run:

- Downloads the tfplan artifact

- Executes `terraform apply tfplan`

This keeps apply manual and auditable while running plan automatically on PRs/pushes.
