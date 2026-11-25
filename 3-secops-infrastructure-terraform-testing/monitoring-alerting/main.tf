terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0.0, < 7.0.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 5.0.0, < 7.0.0"
    }
  }
}

provider "google" {
  project = "yuvaraj-internal-project"
  region  = "asia-south1"
}

provider "google-beta" {
  project = "yuvaraj-internal-project"
  region  = "asia-south1"
}

module "monitoring_alerting" {
  source           = "git::https://github.com/yuva-cloud-devops/gcp-terraform-custom-modules.git//secops-infrastructure/monitoring-alerting-infra?ref=main"
  config_file_path = "${path.module}/monitoring-alerting.yaml"
}

# ==============================================================================
# Outputs: Monitoring & Alerting Setup
# ==============================================================================

output "scoping_project" {
  description = "Centralized Cloud Monitoring scoping project"
  value       = module.monitoring_alerting.scoping_project
}

output "notification_channels" {
  description = "Created Cloud Monitoring notification channels"
  value       = module.monitoring_alerting.notification_channels
}

output "cis_alert_policies" {
  description = "Created CIS GCP Benchmark v3 security alert policies"
  value       = module.monitoring_alerting.cis_alert_policies
}

output "custom_alert_policies" {
  description = "Created operational metric threshold alert policies"
  value       = module.monitoring_alerting.custom_alert_policies
}

output "monitoring_summary" {
  description = "Summary count of monitoring resources provisioned"
  value       = module.monitoring_alerting.monitoring_summary
}
