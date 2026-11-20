# SecOps Domain 1: Audit Logging, Log Sinks & CIS Compliance

This directory provisions automated **Data Access Audit Logging**, centralized multi-destination **Log Sinks**, compliance storage buckets with **WORM retention policies**, and all **CIS GCP Foundations Benchmark (v3) security metric filters** (Controls 2.4 through 2.12).

---

## Architecture Topology

```mermaid
flowchart LR
    AuditSource["GCP Project Audit Logs\n(Admin Read, Data Read, Data Write)"] --> Sinks{"Centralized Log Sinks"}
    
    Sinks -->|WORM 365d Cold Retention| GCS["Cloud Storage\nsecops-audit-cold-storage-..."]
    Sinks -->|SQL Threat Hunting| BQ["BigQuery Dataset\nsecops_audit_analytics"]
    Sinks -->|High Severity Stream (>= WARN)| PubSub["Pub/Sub SIEM Topic\nsiem-audit-stream"]

    AuditSource --> Metrics["Security Metric Filters\n(CIS 2.4 to 2.12 + Custom)"]
    Metrics --> Alerts["Cloud Monitoring Alerts"]
```

---

## Components & Technical Specifications

Driven declaratively by [`audit-compliance.yaml`](./audit-compliance.yaml):

### 1. Data Access Audit Logging
Enables `ADMIN_READ`, `DATA_READ`, and `DATA_WRITE` log types across `allServices` at the project level, ensuring complete visibility into user and service account data access.

### 2. Managed Multi-Tier Export Destinations
* **Cloud Storage Cold Storage**:
  * Bucket: `secops-audit-cold-storage-yuvaraj-internal-project`
  * Retention Policy: 365-day Write Once, Read Many (WORM) retention period with versioning enabled.
  * Lifecycle: Automatically transitions objects to `COLDLINE` storage class after 90 days.
* **BigQuery Security Analytics**:
  * Dataset: `secops_audit_analytics` in `asia-south1`.
  * Purpose: Enables high-speed SQL analytics and threat hunting across security audit trails.
* **Pub/Sub SIEM Streaming**:
  * Topic: `siem-audit-stream`.
  * Purpose: Streams real-time audit logs with severity $\ge$ `WARNING` to external SIEM platforms (Splunk, Chronicle, Datadog).

### 3. CIS GCP Benchmark v3 Security Metrics

Automated log-based metrics capturing critical configuration and security drift:

| Metric Name | CIS Control | Description | Filter Target |
| :--- | :---: | :--- | :--- |
| `cis_iam_policy_changes` | **2.4** | IAM role and policy assignment modifications | `SetIamPolicy` or `SetOrgPolicy` |
| `cis_audit_config_changes` | **2.5** | Changes to audit logging configuration | `SetIamPolicy` on `auditConfigDeltas` |
| `cis_custom_role_changes` | **2.6** | Custom IAM role creation, deletion, or updates | `CreateRole`, `DeleteRole`, `UpdateRole` |
| `cis_firewall_rule_changes`| **2.7** | VPC firewall rule creation, deletion, or patching | `insert`, `delete`, `patch` on firewalls |
| `cis_network_route_changes`| **2.8** | VPC network route modifications | `insert` or `delete` on routes |
| `cis_vpc_network_changes` | **2.9** | VPC network or subnet creation/modification | `insert`, `delete`, `patch` on networks |
| `cis_storage_iam_changes` | **2.10** | Cloud Storage bucket IAM permission changes | `storage.setIamPermissions` |
| `cis_cloud_sql_changes` | **2.11** | Cloud SQL database instance configuration updates | `update` or `delete` on Cloud SQL |
| `cis_kms_key_destruction` | **2.12** | Cloud KMS key scheduled destruction | `DestroyCryptoKeyVersion` |
| `secret_manager_unauthorized_access` | Custom | Unauthorized Secret Manager access attempts | `status.code = 7` (PERMISSION_DENIED) |

---

## Live Deployment Outputs

Captured in [`output.txt`](./output.txt):

```text
storage_buckets = {
  "secops-audit-cold-storage-yuvaraj-internal-project" = {
    "location" = "ASIA-SOUTH1"
    "name"     = "secops-audit-cold-storage-yuvaraj-internal-project"
    "url"      = "gs://secops-audit-cold-storage-yuvaraj-internal-project"
  }
}
bigquery_datasets = {
  "secops_audit_analytics" = {
    "dataset_id" = "secops_audit_analytics"
    "location"   = "asia-south1"
  }
}
pubsub_topics = {
  "siem-audit-stream" = {
    "name" = "siem-audit-stream"
  }
}
summary = {
  "audit_services_count"   = 1
  "bigquery_dataset_count" = 1
  "project_sinks_count"    = 3
  "pubsub_topics_count"    = 1
  "security_metrics_count" = 10
  "storage_buckets_count"  = 1
}
```

---

## Execution Guide

```powershell
cd d:\GCP-DevOps-WorkSpace\gcp-terraform-best-practices\3-secops-infrastructure-terraform-testing\audit-compliance

# Initialize modules and provider
terraform init

# Validate configuration
terraform validate

# Review deployment plan
terraform plan

# Deploy audit and compliance layer
terraform apply
```

---

## Verification Commands

```powershell
# List log sinks
gcloud logging sinks list --project=yuvaraj-internal-project

# Verify log-based security metrics
gcloud logging metrics list --project=yuvaraj-internal-project

# Inspect cold storage bucket retention
gcloud storage buckets describe gs://secops-audit-cold-storage-yuvaraj-internal-project --format="yaml(retentionPolicy,lifecycle)"
```
