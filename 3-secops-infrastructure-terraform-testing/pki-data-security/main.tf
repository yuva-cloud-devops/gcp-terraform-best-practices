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
  project               = "yuvaraj-internal-project"
  region                = "asia-south1"
  user_project_override = true
  billing_project       = "yuvaraj-internal-project"
}

provider "google-beta" {
  project               = "yuvaraj-internal-project"
  region                = "asia-south1"
  user_project_override = true
  billing_project       = "yuvaraj-internal-project"
}

module "pki_data_security" {
  source           = "git::https://github.com/yuva-cloud-devops/gcp-terraform-custom-modules.git//secops-infrastructure/pki-data-security-infra?ref=main"
  config_file_path = "./pki-data-security.yaml"
}


# ==============================================================================
# Outputs: PKI & Data Secuirty Infra outputs
# ==============================================================================

output "ca_pools" {
  description = "Created CAS pools"
  value       = module.pki_data_security.ca_pools
}

output "certificate_authorities" {
  description = "Created Certificate Authorities"
  value       = module.pki_data_security.certificate_authorities
}

output "dns_authorizations" {
  description = "Created Certificate Manager DNS authorizations"
  value       = module.pki_data_security.dns_authorizations
}

output "certificate_maps" {
  description = "Created Certificate Maps"
  value       = module.pki_data_security.certificate_maps
}

output "dlp_inspect_templates" {
  description = "Created DLP inspection templates"
  value       = module.pki_data_security.dlp_inspect_templates
}

output "dlp_deidentify_templates" {
  description = "Created DLP de-identification templates"
  value       = module.pki_data_security.dlp_deidentify_templates
}
