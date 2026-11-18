project_id                  = "yuvaraj-internal-project"
region                      = "asia-south1"
location                    = "ASIA-SOUTH1"
bucket_name                 = "gcp-tfplans-instancetemplate-strorage-bucket"
storage_class               = "STANDARD"
uniform_bucket_level_access = true
public_access_prevention    = "enforced"
force_destroy               = false
versioning_enabled          = false

# Update this value after running `terraform plan` if your existing bucket has a different retention policy or labels
soft_delete_retention_duration_seconds = 604800
labels                                 = {}

