
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
  project = "yuvaraj-internal-project"
  region  = "asia-south1"
}


module "crypto_secrets" {
  source           = "git::https://github.com/yuva-cloud-devops/gcp-terraform-custom-modules.git//secops-infrastructure/crypto-secrets-infra?ref=main"
  config_file_path = "${path.module}/crypto-secrets-minimal.yaml"
}

output "key_id" {
  value = module.crypto_secrets.key_ids_by_name["app-data-key"]
}

output "secret_id" {
  value = module.crypto_secrets.secret_ids["app-db-password"]
}

output "summary" {
  description = "Summary counts of provisioned security resources."
  value       = module.crypto_secrets.summary
}
