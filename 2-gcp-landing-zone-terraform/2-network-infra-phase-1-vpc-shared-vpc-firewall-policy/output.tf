output "vpc_summary" {
  value = module.networking.vpcs
}

output "subnet_summary" {
  value = module.networking.subnets
}

output "router_summary" {
  value = module.networking.routers
}

output "nat_summary" {
  value = module.networking.nat_gateways
}

output "firewall_summary" {
  value = module.networking.firewall_rules
}

output "private_service_access_ranges" {
  value = module.networking.private_service_access_ranges
}

output "private_service_access_connections" {
  value = module.networking.private_service_access_connections
}



# ==============================================================================
# SHARED VPC ORCHESTRATION OUTPUTS
# ==============================================================================

output "host_project_id" {
  description = "The GCP Project ID configured as the Shared VPC Host Project."
  value       = module.shared_vpc.host_project_id
}

output "attached_service_projects" {
  description = "List of GCP Project IDs successfully attached as Shared VPC Service Projects."
  value       = module.shared_vpc.attached_service_projects
}

output "configured_subnet_delegations" {
  description = "Total number of 'roles/compute.networkUser' IAM delegations provisioned across all subnets."
  value       = module.shared_vpc.configured_subnet_delegations
}

output "service_project_attachments" {
  description = "Map of service project IDs to their google_compute_shared_vpc_service_project resource details."
  value       = module.shared_vpc.service_project_attachments
}



# ==============================================================================
# HIERARCHICAL FIREWALL EXAMPLE: OUTPUTS
# ==============================================================================

output "policy_id" {
  description = "Resource identifier of the created hierarchical firewall policy."
  value       = module.hierarchical_firewalls.policy_id
}

output "policy_name" {
  description = "Configured short name of the hierarchical firewall policy."
  value       = module.hierarchical_firewalls.policy_name
}

output "attached_target" {
  description = "Target Organization or Folder URI where guardrail policy is attached."
  value       = module.hierarchical_firewalls.attached_target
}

output "association_id" {
  description = "Resource identifier of the policy association."
  value       = module.hierarchical_firewalls.association_id
}

output "configured_rule_priorities" {
  description = "List of configured rule priorities in evaluation order."
  value       = module.hierarchical_firewalls.configured_rule_priorities
}

output "rules_summary" {
  description = "Summary map of provisioned firewall rules."
  value       = module.hierarchical_firewalls.rules_summary
}
