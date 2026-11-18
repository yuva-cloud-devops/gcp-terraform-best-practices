# Bootstrap Project and GCS Remote State Bucket Setup

This guide provides step-by-step instructions for creating the bootstrap project and the Google Cloud Storage (GCS) bucket required to store remote Terraform state files for the Landing Zone foundation. It also includes critical bootstrap configurations, provider overrides, quota project mechanics, enterprise service account impersonation, and troubleshooting solutions for common foundation deployment issues.

---

## Configuration Summary

| Parameter | Value | Description |
| :--- | :--- | :--- |
| **Project ID** | `bootstrap-landing-zone-setup` | Dedicated bootstrap project for management & state |
| **Region** | `asia-south1` | Regional location (Mumbai) |
| **GCS Bucket Location** | `ASIA-SOUTH1` | Cloud Storage bucket location |
| **GCS Bucket Name** | `gcp-terraform-landing-zone-tfstate-bucket` | Remote backend bucket for Terraform state |
| **GCS Bucket URI** | `gs://gcp-terraform-landing-zone-tfstate-bucket` | Full Cloud Storage URI |
| **Access Model** | Uniform Bucket-Level Access (UBLA) | Enforced uniform IAM permissions |
| **Object Versioning** | Enabled | Protects against accidental state corruption/deletion |

---

## Prerequisites

Ensure you have:
1. Google Cloud SDK (`gcloud`) installed and authenticated:
   ```powershell
   gcloud auth login
   gcloud auth application-default login
   ```
2. Set the ADC quota project to your bootstrap project (avoids `Error 403: SERVICE_DISABLED` / quota errors on org-level APIs):
   ```powershell
   gcloud auth application-default set-quota-project bootstrap-landing-zone-setup
   ```
3. Your active Google Cloud **Billing Account ID**:
   ```powershell
   gcloud billing accounts list
   ```
4. Required IAM roles assigned at the Organization / Folder level (`roles/resourcemanager.organizationAdmin`, `roles/resourcemanager.folderAdmin`, `roles/resourcemanager.projectCreator`, `roles/billing.user`, `roles/orgpolicy.policyAdmin`).

---

## Step 1: Create the Bootstrap Project

Create the dedicated project `bootstrap-landing-zone-setup`:

```powershell
# If creating under an Organization
gcloud projects create bootstrap-landing-zone-setup `
  --name="Bootstrap Landing Zone Setup" `
  --organization="<YOUR_ORGANIZATION_ID>"

# Alternatively, if creating under a specific Folder
# gcloud projects create bootstrap-landing-zone-setup `
#   --name="Bootstrap Landing Zone Setup" `
#   --folder="<YOUR_FOLDER_ID>"

# Set the active project in gcloud
gcloud config set project bootstrap-landing-zone-setup
```

*(For Linux/macOS/Bash shells, replace ``` ` ``` with `\` for line continuation).*

---

## Step 2: Link Billing Account

Attach your billing account to ensure APIs can be enabled and resources provisioned:

```powershell
# Set your billing account ID
$BILLING_ACCOUNT_ID="<YOUR_BILLING_ACCOUNT_ID>"

# Link project to the billing account
gcloud billing projects link bootstrap-landing-zone-setup `
  --billing-account=$BILLING_ACCOUNT_ID
```

Verify that billing is successfully enabled:
```powershell
gcloud billing projects describe bootstrap-landing-zone-setup
```

---

## Step 3: Enable Required GCP Service APIs

> [!IMPORTANT]
> Once `bootstrap-landing-zone-setup` is configured as your billing/quota project, Google routes all organization, folder, and resource management API calls through it. If foundational APIs like `cloudresourcemanager.googleapis.com` are not enabled on this project, organization and folder creation calls will fail.

Enable all required APIs on `bootstrap-landing-zone-setup` in one command:

```powershell
gcloud services enable `
  cloudresourcemanager.googleapis.com `
  orgpolicy.googleapis.com `
  essentialcontacts.googleapis.com `
  iam.googleapis.com `
  serviceusage.googleapis.com `
  cloudbilling.googleapis.com `
  compute.googleapis.com `
  --project bootstrap-landing-zone-setup
```

*(Wait **1 to 2 minutes** after running this command for Google Cloud API propagation).*

---

## Step 4: Enforce Organization Policy (Skip Default Network Creation)

By default, GCP automatically provisions a `default` VPC with open firewall rules in every new project. When `auto_create_network = false` is configured, Terraform will attempt to delete these default firewall rules, which will fail if your credentials lack `compute.firewalls.delete` on the newly provisioned project.

To enforce landing zone best practices and avoid deletion permission errors, enforce the organization policy:

```powershell
gcloud resource-manager org-policies enable-enforce compute.skipDefaultNetworkCreation `
  --organization="<YOUR_ORGANIZATION_ID>"
```

*Console path:* **Organization** > **IAM & Admin** > **Organization Policies** > Search **"Skip default network creation"** (`compute.skipDefaultNetworkCreation`) > **Edit Policy** > Set to **Enforce**.

---

## Step 5: Create and Secure the Terraform State GCS Bucket

### 5.1 Create the Bucket with Uniform Bucket-Level Access
Create the state bucket in `asia-south1` with uniform bucket-level access and public access prevention:

```powershell
gcloud storage buckets create gs://gcp-terraform-landing-zone-tfstate-bucket `
  --project=bootstrap-landing-zone-setup `
  --location=ASIA-SOUTH1 `
  --default-storage-class=STANDARD `
  --uniform-bucket-level-access `
  --public-access-prevention
```

### 5.2 Enable Object Versioning
Object versioning preserves state history and enables state recovery in case of accidental corruption:

```powershell
gcloud storage buckets update gs://gcp-terraform-landing-zone-tfstate-bucket `
  --versioning
```

### 5.3 (Optional) Set Soft Delete Policy
Set or inspect retention policies to protect against state loss:

```powershell
# Set soft-delete retention to 7 days (604800 seconds)
gcloud storage buckets update gs://gcp-terraform-landing-zone-tfstate-bucket `
  --soft-delete-retention-duration=7d
```

### 5.4 Verify Bucket Configuration
```powershell
gcloud storage buckets describe gs://gcp-terraform-landing-zone-tfstate-bucket --format="yaml(name,location,storageClass,versioning,iamConfiguration)"
```

---

## Step 6: Configure Terraform Provider & Remote Backend

In `1-foundation-infra/provider.tf`, configure the GCS backend and provider authentication.

### Option A: Local ADC with Quota Project (Development / Testing)

When using personal credentials (`gcloud auth application-default login`), configure `user_project_override` and `billing_project`:

```terraform
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  backend "gcs" {
    bucket = "gcp-terraform-landing-zone-tfstate-bucket"
    prefix = "foundation"
  }
}

provider "google" {
  project               = "bootstrap-landing-zone-setup"
  region                = "asia-south1"
  user_project_override = true
  billing_project       = "bootstrap-landing-zone-setup"
}
```

### Option B: The Enterprise Standard — Service Account Impersonation

In enterprise landing zones, engineers do not deploy infrastructure using personal user credentials. Instead, they use **Service Account Impersonation**:

* **No Quota Configuration Needed**: Service accounts automatically route API quotas through their home project.
* **No `user_project_override`**: Native service account authentication bypasses client-side quota overrides.
* **Auditable & Least-Privilege**: All actions in Cloud Audit Logs show the dedicated automation identity.

```terraform
provider "google" {
  alias = "impersonated"
}

provider "google" {
  project                     = "bootstrap-landing-zone-setup"
  region                      = "asia-south1"
  impersonate_service_account = "terraform-foundation@bootstrap-landing-zone-setup.iam.gserviceaccount.com"
}
```

---

## Step 7: Initialize or Migrate State

### Scenario A: Clean Initialization with Remote Backend
If starting fresh:
```powershell
cd d:\GCP-DevOps-WorkSpace\gcp-terraform-best-practices\2-gcp-landing-zone-terraform\1-foundation-infra
terraform init
```

### Scenario B: Migrating from Local State to GCS State Bucket
If you initially tested or bootstrapped resources using a local backend (`backend "local" {}` or no backend):

1. Add the `backend "gcs" { ... }` block to `provider.tf`.
2. Run migration command:
   ```powershell
   terraform init -migrate-state
   ```
3. Type `yes` when prompted to copy existing local state into `gs://gcp-terraform-landing-zone-tfstate-bucket/foundation/default.tfstate`.

---

## Quota Projects: Cost, Purpose & FAQ

### Does a Quota Project cause billing charges or move resources?
**No.** Setting a quota project does not incur costs or change resource boundaries:
1. **100% Free**: Foundational management APIs (`cloudresourcemanager`, `iam`, `essentialcontacts`, `orgpolicy`) carry **zero monetary cost**.
2. **Tracks Rate Limits (QPS) Only**: Organization-level resources (folders, org IAM, org policies) belong to the Organization, not any project. Google requires a designated quota project solely to track API queries per second (QPS) to avoid abuse.
3. **Why Google throws Error 403 when removed**: Personal user credentials (`gcloud auth application-default login`) lack an intrinsic quota container. Without a designated quota project, Google Cloud rejects calls to organization-scoped APIs.

### How to Revert ADC Quota Project & Provider Configuration
If you ever need to return your local environment to its original state:

1. **Revert `1-foundation-infra/provider.tf`**:
   ```terraform
   provider "google" {
     project = "bootstrap-landing-zone-setup"
     region  = "asia-south1"
   }
   ```
2. **Unset the ADC Quota Project in `gcloud`**:
   ```powershell
   gcloud auth application-default unset-quota-project
   ```

---

## Common Deployment Issues & Troubleshooting

During the deployment of `1-foundation-infra`, common issues may arise. Follow these verified fixes:

### Issue 1: Fix Quota Project 403 Errors (`SERVICE_DISABLED`)
```text
Error creating Contact: googleapi: Error 403: Your application is authenticating by using local Application Default Credentials. The essentialcontacts.googleapis.com API requires a quota project, which is not set by default.
Reason: "SERVICE_DISABLED"
```

* **Cause:** Personal user credentials (ADC) require an explicit billing/quota project when calling org-scoped APIs (`orgpolicy.googleapis.com`, `essentialcontacts.googleapis.com`, `cloudresourcemanager.googleapis.com`), and those APIs must be enabled on that project.
* **Fix:**
  1. Ensure `provider.tf` includes `user_project_override = true` and `billing_project = "bootstrap-landing-zone-setup"`.
  2. Run the one-shot API enable command:
     ```powershell
     gcloud auth application-default set-quota-project bootstrap-landing-zone-setup
     gcloud services enable cloudresourcemanager.googleapis.com orgpolicy.googleapis.com essentialcontacts.googleapis.com iam.googleapis.com serviceusage.googleapis.com cloudbilling.googleapis.com compute.googleapis.com --project bootstrap-landing-zone-setup
     ```
  3. Wait 1 to 2 minutes for API propagation.

---

### Issue 2: Fix `Cannot destroy project as deletion_policy is set to PREVENT`
```text
Error: Cannot destroy project net-core-networking-core-g3t6 as its deletion_policy is set to PREVENT.
```

* **Cause:** In a previous `terraform apply`, project creation failed halfway (e.g., during firewall deletion). When a resource fails during creation, Terraform marks it as **tainted** (damaged) in state and plans to destroy and recreate it. Because `lien: true` in `foundation.yaml` sets `deletion_policy = "PREVENT"`, Terraform protects the project by blocking deletion and throwing this error.
* **Fix Options:**
  * **Option A (Recommended - Keep existing projects and do not recreate):** Untaint the project resources in Terraform state:
    ```powershell
    terraform untaint 'module.foundation_infrastructure.google_project.projects["ecommerce-dev"]'
    terraform untaint 'module.foundation_infrastructure.google_project.projects["ecommerce-prod"]'
    ```
  * **Option B (Recreate projects from scratch):** Temporarily set `lien: false` under the affected projects in `foundation.yaml`. Re-run `terraform apply`, then re-enable `lien: true`.

---

### Issue 3: Fix Firewall Deletion 403 (`Required 'compute.firewalls.delete'`)
```text
Error deleting default network in project acme-dev-...: Error deleting firewall: googleapi: Error 403: Required 'compute.firewalls.delete' permission
```

* **Cause:** When `auto_create_network = false` is configured on `google_project`, Terraform provisions the project and immediately attempts to clean up the auto-generated `default` network and firewalls. The deployer identity has permission to create projects but lacks `compute.firewalls.delete` in the newly created projects.
* **Fix:** Once `orgpolicy.googleapis.com` is enabled and `user_project_override = true` is set, the Terraform resource:
  ```text
  module.foundation_infrastructure.google_org_policy_policy.boolean_policies["compute.skipDefaultNetworkCreation"]
  ```
  will apply successfully. Once enforced, GCP never creates default VPC networks or default firewall rules in new projects, permanently preventing this 403 error.
  *(Alternatively, enforce it immediately via gcloud)*:
  ```powershell
  gcloud resource-manager org-policies enable-enforce compute.skipDefaultNetworkCreation --organization="<YOUR_ORGANIZATION_ID>"
  ```

---

### Issue 4: IAM Policy Errors (`User ...+demo@... does not exist`)
```text
Error: Error applying IAM policy: User venkateshprabhu.gs+demo@quadrasystems.net does not exist., badRequest
Error: Error applying IAM policy: User balasubramaniam.m+demo@quadrasystems.net does not exist., badRequest
```

* **Cause:** Email aliases/tags (e.g., `+demo`) are only supported for **Essential Contacts** (notification recipients). Under Cloud IAM (`organization_iam`, `top_level_folders`, `sub_folders`, and `projects.iam`), GCP requires every `user:email` to be an existing, registered account in Cloud Identity or Google Workspace.
* **Fix:** In `foundation.yaml`, revert all IAM member bindings to real Cloud Identity user accounts. Keep aliases strictly under `essential_contacts`:
  ```yaml
  # 1. Essential Contacts can use the alias:
  essential_contacts:
    - email: "balasubramaniam.m+demo@quadrasystems.net"  # Allowed

  # 2. Organization IAM MUST be real Cloud Identity users:
  organization_iam:
    - role: "roles/billing.viewer"
      members:
        - "user:venkateshprabhu.gs@quadrasystems.net"    # Real user
  ```

---

### Issue 5: Invalid Label Syntax (`invalid project label`)
```text
Error: error creating project net-core-networking-core-g3t6: field [labels] has issue [invalid project label]
```

* **Cause:** Spaces or invalid characters are present in the labels block (e.g., `management: "network team"`). GCP project labels only accept lowercase letters, numbers, hyphens (`-`), and underscores (`_`).
* **Fix:** In `foundation.yaml`, replace spaces with hyphens or underscores:
  ```yaml
  labels:
    environment: "core"
    management: "network-team"    # Fixed: No spaces
  ```

---

## Quick Action Checklist (Resolve Errors & Run Apply)

Follow this exact sequence to unblock your foundation deployment:

```powershell
# 1. Ensure provider.tf has user_project_override & billing_project configured
# 2. Set quota project for local ADC
gcloud auth application-default set-quota-project bootstrap-landing-zone-setup

# 3. Enable foundational APIs in one shot on bootstrap-landing-zone-setup
gcloud services enable `
  cloudresourcemanager.googleapis.com `
  orgpolicy.googleapis.com `
  essentialcontacts.googleapis.com `
  iam.googleapis.com `
  serviceusage.googleapis.com `
  cloudbilling.googleapis.com `
  compute.googleapis.com `
  --project bootstrap-landing-zone-setup

# 4. Wait 1-2 minutes for API propagation

# 5. Untaint any projects marked damaged by previous failed run
cd d:\GCP-DevOps-WorkSpace\gcp-terraform-best-practices\2-gcp-landing-zone-terraform\1-foundation-infra
terraform untaint 'module.foundation_infrastructure.google_project.projects["ecommerce-dev"]'
terraform untaint 'module.foundation_infrastructure.google_project.projects["ecommerce-prod"]'

# 6. Re-run Terraform apply
terraform apply
```
