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

module "container_security" {
  source           = "git::https://github.com/yuva-cloud-devops/gcp-terraform-custom-modules.git//secops-infrastructure/container-security-infra?ref=main"
  config_file_path = "./container-security.yaml"
}

output "container_analysis_notes" {
  value = module.container_security.container_analysis_notes
}

output "attestors" {
  value = module.container_security.attestors
}

output "policy" {
  value = module.container_security.policy
}
