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


module "edge_security" {
  source           = "git::https://github.com/yuva-cloud-devops/gcp-terraform-custom-modules.git//secops-infrastructure/edge-security-infra?ref=main"
  config_file_path = "${path.module}/edge-security.yaml"
}


# ==============================================================================
# Outputs: Edge Security Setup Example
# ==============================================================================

output "cloud_armor_policies" {
  description = "Created Cloud Armor security policies."
  value       = module.edge_security.cloud_armor_policies
}

output "cloud_ids_endpoints" {
  description = "Created Cloud IDS inspection endpoints."
  value       = module.edge_security.cloud_ids_endpoints
}

output "summary" {
  description = "Summary count of provisioned edge security resources."
  value       = module.edge_security.summary
}
