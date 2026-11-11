# ============================================================================
# Target Resource Definition for Reverse Terraform Import
# ============================================================================
# Bucket Name : gcp-tfplans-instancetemplate-strorage-bucket
# Project     : yuvaraj-internal-project
# Location    : asia-south1 (Mumbai)
# Console URL : https://console.cloud.google.com/storage/browser/gcp-tfplans-instancetemplate-strorage-bucket
# Storage URI : gs://gcp-tfplans-instancetemplate-strorage-bucket
# ============================================================================

resource "google_storage_bucket" "tfplans_bucket" {
  name                        = var.bucket_name
  project                     = var.project_id
  location                    = var.location
  storage_class               = var.storage_class
  uniform_bucket_level_access = var.uniform_bucket_level_access
  public_access_prevention    = var.public_access_prevention
  force_destroy               = var.force_destroy
  labels                      = var.labels

  versioning {
    enabled = var.versioning_enabled
  }

  soft_delete_policy {
    retention_duration_seconds = var.soft_delete_retention_duration_seconds
  }

  lifecycle {
    # Safety net: Prevents accidental destruction of the imported bucket
    prevent_destroy = true
  }
}

