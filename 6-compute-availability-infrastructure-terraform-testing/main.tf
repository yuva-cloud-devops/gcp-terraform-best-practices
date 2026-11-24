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
  source           = "git::https://github.com/yuva-cloud-devops/gcp-terraform-custom-modules.git//compute-infrastructure?ref=main"
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






module "availability" {
  # Local source for direct testing and seamless updates:
  source           = "git::https://github.com/yuva-cloud-devops/gcp-terraform-custom-modules.git//availability-infrastructure?ref=main"
  config_file_path = "${path.module}/availability-infrastructure.yaml"

  # Seamlessly passes instance groups created by compute module to the LB backend
  mig_backend_groups = {
    for k, v in module.compute.managed_instance_groups : k => v.instance_group
  }
}

output "availability_summary" {
  description = "Summary counts of all provisioned availability infrastructure components"
  value       = module.availability.availability_summary
}

output "internal_tcp_lbs" {
  description = "Details of provisioned Regional Internal TCP Load Balancers"
  value       = module.availability.internal_tcp_lbs
}

output "internal_http_lbs" {
  description = "Details of provisioned Regional Internal HTTP Load Balancers"
  value       = module.availability.internal_http_lbs
}

output "global_lb_external_ip" {
  description = "Public Global Anycast IPv4 address for the External Application Load Balancer"
  value       = module.availability.primary_external_ip
}

output "external_http_lbs" {
  description = "Details of provisioned Global External Application Load Balancers"
  value       = module.availability.external_http_lbs
}

