terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  # Optional: Configure GCS remote backend after importing the bucket
  backend "gcs" {
    bucket = "gcp-terraform-landing-zone-tfstate-bucket"
    prefix = "foundation"
  }
}

provider "google" {
  project               = "bootstrap-landing-zone-setup"
  region                = "asia-south1"
  user_project_override = true
  billing_project       = "bootstrap-landing-zone-setup"
}
