# ============================================================================
# Declarative Import Block (Terraform >= 1.5.0)
# ============================================================================
# This block tells Terraform to import the existing GCP Cloud Storage bucket
# into the state at `google_storage_bucket.tfplans_bucket`.
#
# Supported ID formats for `google_storage_bucket`:
#   1. "{{project}}/{{name}}" -> "yuvaraj-internal-project/gcp-tfplans-instancetemplate-strorage-bucket"
#   2. "{{name}}"             -> "gcp-tfplans-instancetemplate-strorage-bucket"
#
# NOTE:
# - To auto-generate HCL configuration from GCP, temporarily rename `main.tf`
#   to `main.tf.bak` and run:
#     terraform plan -generate-config-out=generated_bucket.tf
# - To import directly into the parameterized resource in `main.tf`, simply run:
#     terraform plan
#     terraform apply
# ============================================================================

import {
  id = "yuvaraj-internal-project/gcp-tfplans-instancetemplate-strorage-bucket"
  to = google_storage_bucket.tfplans_bucket

  # Note: If using Terraform >= 1.8.0, you can also use variable interpolation:
  # id = "${var.project_id}/${var.bucket_name}"
}
