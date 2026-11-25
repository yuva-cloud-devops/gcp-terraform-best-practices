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

module "dashboards_uptime" {
  source           = "git::https://github.com/yuva-cloud-devops/gcp-terraform-custom-modules.git//secops-infrastructure/dashboards-uptime-infra?ref=main"
  config_file_path = "${path.module}/dashboards-uptime.yaml"
}

# ==============================================================================
# Outputs: Dashboards & Uptime Setup
# ==============================================================================

output "uptime_checks" {
  description = "Created synthetic uptime checks"
  value       = module.dashboards_uptime.uptime_checks
}

output "uptime_failure_alert_policies" {
  description = "Created uptime failure alert policies"
  value       = module.dashboards_uptime.uptime_failure_alert_policies
}

output "ssl_expiry_alert_policies" {
  description = "Created SSL/TLS certificate expiry alert policies"
  value       = module.dashboards_uptime.ssl_expiry_alert_policies
}

output "dashboards" {
  description = "Created Cloud Monitoring dashboards"
  value       = module.dashboards_uptime.dashboards
}

output "dashboards_uptime_summary" {
  description = "Summary metrics of uptime checks and dashboards provisioned"
  value       = module.dashboards_uptime.dashboards_uptime_summary
}
