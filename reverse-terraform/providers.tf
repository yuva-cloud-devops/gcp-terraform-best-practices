terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  # Optional: Configure GCS remote backend after importing the bucket
  # backend "gcs" {
  #   bucket = "gcp-tfplans-instancetemplate-strorage-bucket"
  #   prefix = "terraform/state/reverse-terraform"
  # }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

