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

module "storage" {
  source           = "git::https://github.com/yuva-cloud-devops/gcp-terraform-custom-modules.git//storage-infrastructure?ref=main"
  config_file_path = "${path.module}/storage-infrastructure.yaml"
}

output "storage_summary" {
  value = module.storage.storage_summary
}

output "buckets" {
  value = module.storage.buckets
}

output "snapshot_policies" {
  value = module.storage.snapshot_policies
}

output "zonal_disks" {
  value = module.storage.zonal_disks
}

output "regional_disks" {
  value = module.storage.regional_disks
}

output "filestore_instances" {
  value = module.storage.filestore_instances
}
