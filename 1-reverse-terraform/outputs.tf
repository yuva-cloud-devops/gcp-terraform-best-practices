output "bucket_id" {
  description = "The ID of the imported Cloud Storage bucket."
  value       = google_storage_bucket.tfplans_bucket.id
}

output "bucket_name" {
  description = "The name of the imported Cloud Storage bucket."
  value       = google_storage_bucket.tfplans_bucket.name
}

output "bucket_url" {
  description = "The base GCS URI of the bucket, in the format gs://<bucket-name>."
  value       = google_storage_bucket.tfplans_bucket.url
}

output "bucket_self_link" {
  description = "The URI of the created/imported resource."
  value       = google_storage_bucket.tfplans_bucket.self_link
}

output "bucket_location" {
  description = "The GCP location of the bucket."
  value       = google_storage_bucket.tfplans_bucket.location
}

output "bucket_storage_class" {
  description = "The Storage Class of the bucket."
  value       = google_storage_bucket.tfplans_bucket.storage_class
}

output "cloud_console_url" {
  description = "Direct link to view the bucket in the Google Cloud Console."
  value       = "https://console.cloud.google.com/storage/browser/${google_storage_bucket.tfplans_bucket.name}?project=${google_storage_bucket.tfplans_bucket.project}"
}

