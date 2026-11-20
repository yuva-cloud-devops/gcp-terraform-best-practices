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


module "threat_posture" {
  source           = "git::https://github.com/yuva-cloud-devops/gcp-terraform-custom-modules.git//secops-infrastructure/threat-posture-infra?ref=main"
  config_file_path = "${path.module}/threat-posture.yaml"
}


# ==============================================================================
# Outputs: Threat Posture Infrastructure (SCC & Cloud Asset Inventory)
# ==============================================================================


output "scc_notifications" {
  description = "Security Command Center v2 notification configs."
  value       = module.threat_posture.scc_notification_configs
}

output "cloud_asset_feeds" {
  description = "Cloud Asset Inventory real-time drift feeds."
  value       = module.threat_posture.cloud_asset_feeds
}

output "pubsub_topics" {
  description = "Provisioned Pub/Sub topics."
  value       = module.threat_posture.pubsub_topics
}

output "summary" {
  description = "Summary metrics of threat posture resources."
  value       = module.threat_posture.summary
}
