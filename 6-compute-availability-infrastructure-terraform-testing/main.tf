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


module "compute" {
  # Local source for direct testing and seamless updates:
  source = "../../gcp-terraform-custom-modules/compute-infrastructure"

  # Production Git source (uncomment when tested and pushed to remote):
  # source = "git::https://github.com/yuva-cloud-devops/gcp-terraform-custom-modules.git//compute-infrastructure?ref=main"

  config_file_path = "${path.module}/compute-infrastructure.yaml"
}



output "compute_summary" {
  description = "Summary counts of all provisioned compute infrastructure components"
  value       = module.compute.compute_summary
}

output "instance_templates" {
  description = "Created Google Compute Instance Templates"
  value       = module.compute.instance_templates
}

output "vm_instances" {
  description = "Created standalone VM instances (both template-derived and custom)"
  value       = module.compute.vm_instances
}

output "health_checks" {
  description = "Created autohealing health checks"
  value       = module.compute.health_checks
}

output "managed_instance_groups" {
  description = "Created Regional and Zonal Managed Instance Groups"
  value       = module.compute.managed_instance_groups
}

output "autoscalers" {
  description = "Created autoscaling policies targeting Managed Instance Groups"
  value       = module.compute.autoscalers
}

output "compute_policies" {
  description = "Created disk snapshot and VM start/stop resource policies"
  value       = module.compute.compute_policies
}
