terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0.0, < 7.0.0"
    }
  }
}

provider "google" {
  project = "yuvaraj-internal-project"
  region  = "asia-south1"
}


module "zero_trust" {
  source           = "git::https://github.com/yuva-cloud-devops/gcp-terraform-custom-modules.git//secops-infrastructure/zero-trust-security-infra?ref=main"
  config_file_path = "${path.module}/zero-trust.yaml"
}


# ==============================================================================
# Outputs: Zero-Trust Security Setup Example
# ==============================================================================

output "workload_identity_pools" {
  description = "Created Workload Identity Federation Pools."
  value       = module.zero_trust.workload_identity_pools
}

output "workload_identity_providers" {
  description = "Created Workload Identity Providers."
  value       = module.zero_trust.workload_identity_providers
}

output "service_accounts" {
  description = "Managed WIF Service Accounts."
  value       = module.zero_trust.service_accounts
}

output "iap_firewall_rule" {
  description = "Provisioned IAP TCP Forwarding firewall rule."
  value       = module.zero_trust.iap_firewall_rule
}

output "iap_tunnel_accessors" {
  description = "Members granted IAP Tunnel Accessor."
  value       = module.zero_trust.iap_tunnel_accessors
}

output "summary" {
  description = "Summary count of provisioned resources."
  value       = module.zero_trust.summary
}
