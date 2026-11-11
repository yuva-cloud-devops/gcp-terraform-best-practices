variable "project_id" {
  description = "The GCP Project ID where the Cloud Storage bucket resides."
  type        = string
  default     = "yuvaraj-internal-project"
}

variable "region" {
  description = "Default GCP region for the provider."
  type        = string
  default     = "asia-south1"
}

variable "location" {
  description = "The location of the Cloud Storage bucket (e.g., ASIA-SOUTH1)."
  type        = string
  default     = "ASIA-SOUTH1"
}

variable "bucket_name" {
  description = "The globally unique name of the existing Cloud Storage bucket to import."
  type        = string
  default     = "gcp-tfplans-instancetemplate-strorage-bucket"
}

variable "storage_class" {
  description = "The Storage Class of the bucket (STANDARD, NEARLINE, COLDLINE, ARCHIVE)."
  type        = string
  default     = "STANDARD"
}

variable "uniform_bucket_level_access" {
  description = "Enables Uniform bucket-level access (UBLA) on the bucket."
  type        = bool
  default     = true
}

variable "public_access_prevention" {
  description = "Prevents public access to the bucket (enforced or inherited)."
  type        = string
  default     = "enforced"
}

variable "force_destroy" {
  description = "When deleting a bucket, this boolean option will delete all contained objects."
  type        = bool
  default     = false
}

variable "versioning_enabled" {
  description = "Whether object versioning is enabled on the bucket."
  type        = bool
  default     = false
}

variable "soft_delete_retention_duration_seconds" {
  description = "The duration in seconds that soft-deleted objects in the bucket will be retained (default 7 days = 604800)."
  type        = number
  default     = 604800
}

variable "labels" {
  description = "A map of key/value label pairs Assigned to the bucket."
  type        = map(string)
  default     = {}
}

