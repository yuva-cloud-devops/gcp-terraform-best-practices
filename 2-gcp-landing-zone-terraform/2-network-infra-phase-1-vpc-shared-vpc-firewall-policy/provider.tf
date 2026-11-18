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
    prefix = "network"
  }
}

provider "google" {
  project = "core-network-host-crk2"
  region  = "asia-south1"
}
