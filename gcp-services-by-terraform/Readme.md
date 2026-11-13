# Cloud Infrastructure Competency & Terraform Automation Assessment (GCP)


## Master Competency & Automation Matrix

| # | Competency Checklist Item | GCP Core Services | Terraform Automatable? | Exact Terraform Resources | What CANNOT be Automated / Manual Boundary |
| :-: | :--- | :--- | :-: | :--- | :--- |
| **1** | **Understand cloud architecture & core infrastructure services** | Global VPC, Regions/Zones, Multi-tier architecture | **Concept** | Demonstrated via modular IaC structure | N/A (Demonstrated through architecture and design patterns) |
| **2** | **Provision resource groups/projects & manage accounts** | Resource Manager (Folders, Projects), Cloud Billing | **Yes (90%)** | `google_folder`, `google_project`, `google_project_service` | Cannot create root Organization or initial Billing Account (requires Cloud Identity & billing contract) |
| **3** | **Provision Virtual Networks (GCP VPC)** | VPC Network, Shared VPC (Host & Service) | **Yes (100%)** | `google_compute_network`, `google_compute_shared_vpc_*` | None (100% automatable via code) |
| **4** | **Configure subnets, route tables, & firewalls** | Subnets, Cloud Router, Cloud NAT, Firewalls | **Yes (100%)** | `google_compute_subnetwork`, `google_compute_router`, `google_compute_firewall` | None (100% automatable via code) |
| **5** | **Provision compute resources (Compute Engine)** | Compute Engine (GCE) VMs, MIGs, Templates | **Yes (85%)** | `google_compute_instance`, `google_compute_instance_template` | Cannot manage in-guest OS patching and software runtime updates (use Ansible, Packer, or startup scripts) |
| **6** | **Provision cloud storage services** | Cloud Storage (GCS), Filestore (NFS) | **Yes (100%)** | `google_storage_bucket`, `google_filestore_instance` | None (Buckets, lifecycle, CMEK, and retention are 100% automatable) |
| **7** | **Configure networking, DNS, & load balancing** | Cloud DNS, Cloud Load Balancing, Cloud Armor | **Yes (95%)** | `google_dns_managed_zone`, `google_compute_global_forwarding_rule`, `google_compute_security_policy` | Cannot update NS delegation at external registrars (e.g., GoDaddy, Namecheap) |
| **8** | **Provision managed Kubernetes (GKE)** | GKE (Standard & Autopilot), Node Pools | **Yes (90%)** | `google_container_cluster`, `google_container_node_pool` | Cannot manage in-cluster application workload lifecycle via Terraform alone (use Helm / ArgoCD / GitOps) |
| **9** | **Configure container registries** | Artifact Registry (Docker, Helm, Maven) | **Yes (100%)** | `google_artifact_registry_repository`, `google_artifact_registry_repository_iam_member` | Cannot push container image binaries via Terraform (handled by CI/CD runners / Docker CLI) |
| **10** | **Configure identity, access management (IAM)** | Cloud IAM, Service Accounts, Workload Identity | **Yes (90%)** | `google_project_iam_member`, `google_service_account`, `google_iam_workload_identity_pool` | Cannot create human identity accounts in Google Workspace / Cloud Identity or do the initial bootstrap admin grant |
| **11** | **Provision managed database services** | Cloud SQL (Postgres/MySQL), Spanner, Firestore | **Yes (80%)** | `google_sql_database_instance`, `google_sql_database`, `google_sql_user` | Cannot manage internal table schemas and DDL/DML data migrations (use Flyway, Liquibase, or ORM) |
| **12** | **Configure Key & Secrets Management** | Cloud KMS (CMEK), Secret Manager | **Yes (95%)** | `google_kms_key_ring`, `google_kms_crypto_key`, `google_secret_manager_secret` | Cannot execute physical Cloud HSM key ceremonies or external key manager (EKM) hardware cross-connections |
| **13** | **Configure monitoring, logging, & alerting** | Cloud Logging, Cloud Monitoring, Log Sinks | **Yes (100%)** | `google_logging_organization_sink`, `google_monitoring_alert_policy`, `google_monitoring_notification_channel` | None (Centralized log sinks, notification channels, and alert policies are 100% automatable) |
| **14** | **Security, governance, & compliance** | Org Policies, Project Liens, Resource Tags, SCC | **Yes (95%)** | `google_org_policy_policy`, `google_resource_manager_lien`, `google_tags_*` | Cannot perform third-party compliance audits (SOC2/ISO audits require accredited human auditors) |

---

## Detailed Competency Breakdown

### 1. Understand Cloud Architecture and Core Infrastructure Services
* **GCP Services:** Global software-defined network (Andromeda), Multi-region/Regional/Zonal topology, Shared-responsibility security model.
* **What CAN be automated:** Architectural topology represented as code using modular Terraform patterns with isolated environments (Dev, Staging, Prod).
* **What CANNOT be automated:** Foundational conceptual understanding; validated through design reviews and IaC project structure.

---

### 2. Provision Resource Groups/Projects and Manage Subscriptions/Accounts
* **GCP Services:** Google Cloud Resource Manager (Folders, Projects), Cloud Billing Accounts.
* **What CAN be automated:**
  * Multi-tier folder hierarchy creation (`google_folder`).
  * Project creation with random unique IDs and labels (`google_project`).
  * Programmatic API activation (`google_project_service`).
  * Attaching projects to existing billing accounts.
* **What CANNOT be automated:**
  * Root Organization provisioning: Requires a verified domain in Google Workspace or Cloud Identity.
  * Billing account creation: Requires business legal verification, credit card entry, or offline invoicing agreements with Google.

---

### 3. Provision Virtual Networks (GCP VPC)
* **GCP Services:** Virtual Private Cloud (VPC), Shared VPC (Host & Service projects), VPC Network Peering.
* **What CAN be automated:**
  * Custom mode VPCs (`google_compute_network`).
  * Shared VPC Host Project enablement (`google_compute_shared_vpc_host_project`).
  * Service Project associations (`google_compute_shared_vpc_service_project`).
  * Bi-directional VPC Network Peering (`google_compute_network_peering`).
* **What CANNOT be automated:** None. Networking is 100% declarative and automatable.

---

### 4. Configure Subnets, Route Tables, Network Security, and Firewall Rules
* **GCP Services:** Subnetworks, Secondary IP Ranges (for GKE), Cloud Router (BGP), Cloud NAT, VPC Firewall Rules, Hierarchical Firewall Policies.
* **What CAN be automated:**
  * Subnets with primary and alias/secondary CIDR ranges (`google_compute_subnetwork`).
  * Cloud Routers and Cloud NAT gateways for outbound internet access (`google_compute_router`, `google_compute_router_nat`).
  * Stateful ingress/egress firewall rules by target tags and service accounts (`google_compute_firewall`).
  * Org/Folder level Hierarchical Firewall Policies (`google_compute_firewall_policy`).
* **What CANNOT be automated:** None. 100% automatable.

---

### 5. Provision Compute Resources (GCP Compute Engine)
* **GCP Services:** Compute Engine (GCE) Virtual Machines, Persistent Disks, Instance Templates, Managed Instance Groups (MIGs).
* **What CAN be automated:**
  * VM instances with custom machine types, boot disks, and metadata (`google_compute_instance`).
  * Reusable Instance Templates and auto-healing/auto-scaling MIGs (`google_compute_region_instance_group_manager`).
* **What CANNOT be automated:**
  * In-guest OS software configuration, kernel tuning, and dynamic application patching.
  * *Operational Solution:* Use **Packer** to build immutable golden images or **Ansible** for post-boot configuration.

---

### 6. Provision Cloud Storage Services
* **GCP Services:** Cloud Storage (GCS) Buckets, Cloud Filestore (Managed NFS).
* **What CAN be automated:**
  * GCS Buckets with Uniform Bucket-Level Access, Object Versioning, and Lifecycle rules (`google_storage_bucket`).
  * Customer-Managed Encryption Keys (CMEK) via KMS bindings.
  * Enterprise Filestore instances for shared POSIX file systems (`google_filestore_instance`).
* **What CANNOT be automated:**
  * Physical multi-petabyte offline data import via Google Transfer Appliance.

---

### 7. Configure Cloud Networking, DNS, and Load Balancing
* **GCP Services:** Cloud DNS, Global External Application Load Balancers, Internal Load Balancers, Cloud Armor (WAF/DDoS).
* **What CAN be automated:**
  * Public and Private DNS managed zones and record sets (`google_dns_managed_zone`, `google_dns_record_set`).
  * Global forwarding rules, backend services, URL maps, and health checks.
  * Cloud Armor security policies (WAF rules, geo-fencing, rate limiting) (`google_compute_security_policy`).
* **What CANNOT be automated:**
  * Delegating NS records at third-party domain registrars (GoDaddy, Namecheap, etc.).

---

### 8. Provision Managed Kubernetes Services (GKE)
* **GCP Services:** Google Kubernetes Engine (Standard & Autopilot), Private GKE Clusters, Node Pools, Workload Identity.
* **What CAN be automated:**
  * Private cluster creation with master authorized networks and shielded nodes (`google_container_cluster`).
  * Dynamically scaled node pools with taint/label management (`google_container_node_pool`).
  * Enabling Workload Identity to bridge Kubernetes SAs with GCP IAM SAs.
* **What CANNOT be automated:**
  * Deploying in-cluster workloads (Deployments, Services, Ingress, ConfigMaps).
  * *Operational Solution:* Use **Helm**, **Kustomize**, or **ArgoCD** (GitOps).

---

### 9. Configure Container Registries (Artifact Registry)
* **GCP Services:** Artifact Registry (Docker images, OCI artifacts, Maven, npm, Helm packages).
* **What CAN be automated:**
  * Creating regional/multi-regional repositories (`google_artifact_registry_repository`).
  * Cleanup policies (TTL-based tag retention/deletion).
  * Least-privilege IAM access for build runners and GKE nodes (`google_artifact_registry_repository_iam_member`).
* **What CANNOT be automated:**
  * Building, tagging, and running `docker push` (managed by CI/CD pipelines: Cloud Build, GitHub Actions).

---

### 10. Configure Cloud Identity, Access Management, and Permissions
* **GCP Services:** Cloud IAM (Roles, Members, Policies), Service Accounts, Workload Identity Federation (WIF).
* **What CAN be automated:**
  * Granular IAM role assignments using non-authoritative `google_*_iam_member`.
  * Conditional IAM bindings (Attribute-Based Access Control / ABAC).
  * Custom Workload Service Accounts (`google_service_account`).
  * Deprivileging default Compute Engine Service Accounts (`google_project_default_service_accounts`).
  * Workload Identity Federation pools and providers for keyless CI/CD.
* **What CANNOT be automated:**
  * User provisioning (creating human accounts in Google Workspace or Cloud Identity).
  * The initial bootstrap permission grant (giving Terraform's initial Service Account `Organization Admin`).

---

### 11. Provision Managed Database Services
* **GCP Services:** Cloud SQL (PostgreSQL, MySQL, SQL Server), Cloud Spanner, Firestore.
* **What CAN be automated:**
  * Database instances with HA failover, private IP, automated backups, and maintenance windows (`google_sql_database_instance`).
  * Logical databases and database user credentials (`google_sql_database`, `google_sql_user`).
  * Cloud Spanner instances and database definitions (`google_spanner_instance`).
* **What CANNOT be automated:**
  * Database schema migrations (e.g., `CREATE TABLE`, foreign keys, indexes) and inserting row data.
  * *Operational Solution:* Use application migration tools such as **Flyway**, **Liquibase**, or **Prisma**.

---

### 12. Configure Key Management and Secrets Management Services
* **GCP Services:** Cloud Key Management Service (Cloud KMS), Secret Manager.
* **What CAN be automated:**
  * KMS KeyRings, CryptoKeys, and rotation intervals (`google_kms_key_ring`, `google_kms_crypto_key`).
  * Secret containers and initial secret versions (`google_secret_manager_secret`, `google_secret_manager_secret_version`).
  * Encryptor/Decryptor IAM role grants to GCP service agents for CMEK.
* **What CANNOT be automated:**
  * Physical Cloud HSM key ceremonies or establishing hardware connections with External Key Management (EKM) partners.

---

### 13. Configure Monitoring, Logging, and Alerting Services
* **GCP Services:** Cloud Logging, Cloud Monitoring, Aggregated Log Sinks, Metric Alerts, Notification Channels.
* **What CAN be automated:**
  * Aggregated Organization Log Sinks routing security audit logs to BigQuery, GCS, or Pub/Sub (`google_logging_organization_sink`).
  * Notification channels (Email, Webhook, PagerDuty) (`google_monitoring_notification_channel`).
  * Metric-threshold Alert Policies (CPU spikes, memory limits, 5xx HTTP errors) (`google_monitoring_alert_policy`).
  * Monitoring Dashboards as Code (`google_monitoring_dashboard`).
* **What CANNOT be automated:** None. 100% automatable.

---

### 14. Understand Cloud-Specific Security, Governance, and Compliance
* **GCP Services:** Organization Policies, Essential Contacts, Resource Tags, Project Liens, VPC Service Controls (VPC-SC), Security Command Center (SCC).
* **What CAN be automated:**
  * Org Policies enforcing security guardrails (e.g., disable default VPC, disable external IP) (`google_org_policy_policy`).
  * Project Liens preventing accidental project deletion (`google_resource_manager_lien`).
  * Secure Resource Tags for policy and IAM scoping (`google_tags_*`).
  * Essential Contacts routing automated alerts to SecOps/FinOps (`google_essential_contacts_contact`).
  * VPC Service Controls security perimeters (`google_access_context_manager_*`).
* **What CANNOT be automated:**
  * Formal regulatory audits and third-party certifications (SOC 2, ISO 27001, PCI-DSS compliance sign-offs require accredited human auditors).