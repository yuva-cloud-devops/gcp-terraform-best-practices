# Prerequisites & IAM Permissions Before Running Terraform

## Overview

Before deploying the Google Cloud Landing Zone foundation with Terraform, ensure the organization structure, permissions, and required identifiers are available. Terraform creates and manages folders, projects, IAM bindings, resource tags, organizational policies, Shared VPC configurations, and other foundation resources.

---

## Required Identifiers

Collect the following values before running Terraform:

- **GCP Organization ID**: e.g., `278632878375` (`cloudgeeks.online`)
- **Billing Account ID**: e.g., `012D91-0F6EE1-44CE12` (GCP Master Billing Account)
- **Bootstrap Project ID**: `bootstrap-landing-zone-setup`
- **Remote State Bucket**: `gcp-terraform-landing-zone-tfstate-bucket` (Region: `asia-south1`)
- **Folder Hierarchy Design**: `core`, `workloads` (`development`, `production`), `sandbox`
- **Project Naming Conventions**: `<env>-<workload>-<random-suffix>` (e.g., `core-network-host-xxxx`, `dev-ecommerce-devlopment-xxxx`)

---

## Required IAM Permissions

### Organization Level

Grant the Terraform deployment user or bootstrap service account:

- `roles/resourcemanager.organizationAdmin`: Manage organization resources, IAM, and settings
- `roles/resourcemanager.folderAdmin`: Create and manage folders in the hierarchy
- `roles/resourcemanager.projectCreator`: Create and associate new projects
- `roles/compute.xpnAdmin`: Administer Shared VPC host projects and service project attachments
- `roles/resourcemanager.tagAdmin`: Create and manage organization-wide Tag Keys and Tag Values
- `roles/resourcemanager.tagUser`: Attach Tag Values to folders and projects

### Optional / Feature-Specific Roles

Required if your foundation manages these features:

- `roles/orgpolicy.policyAdmin`: Configure organization policies (e.g., `compute.skipDefaultNetworkCreation`)
- `roles/essentialcontacts.admin`: Manage notification contacts at the organization level
- `roles/logging.configWriter`: Configure organization log sinks and centralized logging
- `roles/resourcemanager.projectDeleter`: Required if projects need to be destroyed during teardown

### Billing Account Level

- `roles/billing.user`: Required on the Cloud Billing Account to attach newly created projects to billing.

---

## Bootstrap Validation Checklist

- [x] Organization is accessible (`gcloud organizations list`).
- [x] Billing Account ID is verified and active (`gcloud billing accounts list`).
- [x] Required IAM roles are assigned to the deployment identity.
- [x] Bootstrap project `bootstrap-landing-zone-setup` is created and linked to billing.
- [x] Foundational APIs enabled on the bootstrap project (`cloudresourcemanager`, `orgpolicy`, `essentialcontacts`, `iam`, `serviceusage`, `cloudbilling`, `compute`).
- [x] GCS state bucket `gcp-terraform-landing-zone-tfstate-bucket` provisioned with UBLA and versioning.
- [x] ADC Quota project configured (`gcloud auth application-default set-quota-project bootstrap-landing-zone-setup`).

---

## Next Steps

1. Review and execute the bootstrap setup in [2-bootstrap-project.md](file:///d:/GCP-DevOps-WorkSpace/gcp-terraform-best-practices/2-gcp-landing-zone-terraform/0-bootstrap/2-bootstrap-project.md).
2. Deploy the organization structure in [1-foundation-infra/README.md](file:///d:/GCP-DevOps-WorkSpace/gcp-terraform-best-practices/2-gcp-landing-zone-terraform/1-foundation-infra/README.md).
3. Deploy Shared VPC and firewall policies in [2-network-infra-phase-1-vpc-shared-vpc-firewall-policy/README.md](file:///d:/GCP-DevOps-WorkSpace/gcp-terraform-best-practices/2-gcp-landing-zone-terraform/2-network-infra-phase-1-vpc-shared-vpc-firewall-policy/README.md).
