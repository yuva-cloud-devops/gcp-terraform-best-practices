# SecOps Domain 7: Zero-Trust Identity & Access Management

This directory implements keyless Zero-Trust identity federation and secure administrative access: **Workload Identity Federation (WIF)** for GitHub Actions CI/CD pipelines (eliminating static JSON service account keys) and **Identity-Aware Proxy (IAP) TCP forwarding** for bastion-less, private-IP-only virtual machine management.

---

## Zero-Trust Architecture

```mermaid
flowchart TD
    subgraph GitHub["GitHub Actions CI/CD (yuva-cloud-devops/gcp-testing-github-repo)"]
        GHA["GitHub Actions Runner\n(OIDC JWT Token)"]
    end

    subgraph WIF["Workload Identity Federation (yuvaraj-internal-project)"]
        Pool["WIF Pool: pool-github-actions"]
        Provider["OIDC Provider: provider-github\n(https://token.actions.githubusercontent.com)"]
        Pool --- Provider
        
        SA["Service Account: sa-cicd-deployer\n(roles/viewer, roles/compute.networkViewer)"]
        
        GHA ==>|Exchange OIDC Token| Provider
        Provider ==>|Impersonate SA (Short-Lived Token)| SA
    end

    subgraph IAP_Access["Zero-Public-IP Administrative Access"]
        AdminUser["SecOps Engineer\n(bharath.k / yuvaraj.k)"]
        IAP_Service["Cloud Identity-Aware Proxy (IAP)\n(35.235.240.0/20)"]
        IAP_FW["Firewall Rule: allow-iap-tcp-ingress\n(Ports 22 SSH, 3389 RDP)"]
        PrivateVM["Workload Private VM\n(No Public IP / Internal Only)"]

        AdminUser ==>|gcloud compute ssh --tunnel-through-iap| IAP_Service
        IAP_Service ==>|IAM & Context-Aware Authorization| IAP_FW
        IAP_FW ==>|TCP Forwarding| PrivateVM
    end
```

---

## Technical Specifications

Driven declaratively by [`zero-trust.yaml`](./zero-trust.yaml):

### 1. Workload Identity Federation (WIF)
* **Pool Name**: `pool-github-actions`
* **Provider Name**: `provider-github`
  * Issuer: `https://token.actions.githubusercontent.com`
  * Attribute Condition: `assertion.repository_owner == 'yuva-cloud-devops'` (restricts token issuance strictly to organizations you own).
  * Attribute Mappings:
    * `google.subject` $\to$ `assertion.sub`
    * `attribute.actor` $\to$ `assertion.actor`
    * `attribute.repository` $\to$ `assertion.repository`
    * `attribute.repository_owner` $\to$ `assertion.repository_owner`

### 2. Impersonated Keyless Service Account
* **Service Account**: `sa-cicd-deployer`
* **Granted Roles**: `roles/viewer`, `roles/compute.networkViewer`.
* **Workload Identity Binding**: Binds strictly to GitHub repository `yuva-cloud-devops/gcp-testing-github-repo`.

### 3. Identity-Aware Proxy (IAP) TCP Forwarding
* **Firewall Rule**: `allow-iap-tcp-ingress`
  * Network: `default`
  * Source CIDR: `35.235.240.0/20` (Google's official IAP proxy netblock).
  * Target Tags: `allow-iap-ssh`, `allow-iap-rdp`.
  * Ports: TCP `22`, TCP `3389`.
* **Tunnel Accessors**:
  * Grants `roles/iap.tunnelResourceAccessor` to verified Cloud Identity engineers (`user:bharath.k@quadrasystems.net`, `user:yuvaraj.k@quadrasystems.net`).

---

## File Manifest

* [`main.tf`](./main.tf) — Invokes `git::https://github.com/yuva-cloud-devops/gcp-terraform-custom-modules.git//secops-infrastructure/zero-trust-security-infra?ref=main`.
* [`zero-trust.yaml`](./zero-trust.yaml) — Declarative YAML specification for WIF pools, providers, service account bindings, IAP firewall rules, and tunnel accessors.

---

## Execution Guide

```powershell
cd d:\GCP-DevOps-WorkSpace\gcp-terraform-best-practices\3-secops-infrastructure-terraform-testing\zero-trust-security

# Initialize Terraform modules
terraform init

# Validate configuration
terraform validate

# Inspect changes
terraform plan

# Apply zero-trust infrastructure
terraform apply
```

---

## Verification Commands

```powershell
# List Workload Identity Pools
gcloud iam workload-identity-pools list --location=global --project=yuvaraj-internal-project

# List Workload Identity Providers in pool
gcloud iam workload-identity-pools providers list --workload-identity-pool=pool-github-actions --location=global --project=yuvaraj-internal-project

# Verify IAP firewall rule
gcloud compute firewall-rules describe allow-iap-tcp-ingress --project=yuvaraj-internal-project
```
