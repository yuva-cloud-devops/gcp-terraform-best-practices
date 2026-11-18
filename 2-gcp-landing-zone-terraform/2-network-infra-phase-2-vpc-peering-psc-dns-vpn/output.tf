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
# PEERING OUTPUTS
# ==============================================================================

output "local_peerings" {
  description = "Forward peering connections initiated from the Hub VPC."
  value       = module.vpc_peering.local_peerings
}

output "reverse_peerings" {
  description = "Automated reverse peering connections completed in peer networks."
  value       = module.vpc_peering.reverse_peerings
}

output "all_peerings" {
  description = "Consolidated catalog of all peering connections created by the example."
  value       = module.vpc_peering.all_peerings
}

output "peering_states" {
  description = "Operational states (ACTIVE/INACTIVE) of all managed peering connections."
  value       = module.vpc_peering.peering_states
}

output "total_peerings_count" {
  description = "Total number of peering resources created."
  value       = module.vpc_peering.total_peerings_count
}


# ==============================================================================
# CLOUD DNS EXAMPLE: OUTPUTS
# ==============================================================================

output "managed_zones" {
  description = "Map of created Cloud DNS managed zone names to their full resource attributes."
  value       = module.cloud_dns.managed_zones
}

output "zone_dns_names" {
  description = "Map of managed zone names to their fully qualified domain names (dns_name)."
  value       = module.cloud_dns.zone_dns_names
}

output "name_servers" {
  description = "Map of managed zone names to their assigned Cloud DNS name servers."
  value       = module.cloud_dns.name_servers
}

output "records" {
  description = "Map of created DNS record sets keyed by zone/type/name."
  value       = module.cloud_dns.records
}

output "total_zones_count" {
  description = "Total number of Cloud DNS managed zones provisioned."
  value       = module.cloud_dns.total_zones_count
}

output "total_records_count" {
  description = "Total number of DNS record sets provisioned."
  value       = module.cloud_dns.total_records_count
}


# ==============================================================================
# PRIVATE SERVICE CONNECT EXAMPLE: OUTPUTS
# ==============================================================================

output "google_apis_endpoints" {
  description = "Detailed map of provisioned Google APIs PSC endpoints and forwarding rules."
  value       = module.psc.google_apis_endpoints
}

output "service_attachment_endpoints" {
  description = "Detailed map of provisioned SaaS Service Attachment PSC endpoints."
  value       = module.psc.service_attachment_endpoints
}

output "google_apis_ips" {
  description = "Reserved internal IP addresses for Google APIs."
  value       = module.psc.google_apis_ips
}

output "service_attachment_ips" {
  description = "Reserved regional internal IP addresses for SaaS Service Attachments."
  value       = module.psc.service_attachment_ips
}

output "total_google_apis_endpoints" {
  description = "Total number of Google APIs PSC endpoints created."
  value       = module.psc.total_google_apis_endpoints
}

output "total_service_attachment_endpoints" {
  description = "Total number of SaaS Service Attachment PSC endpoints created."
  value       = module.psc.total_service_attachment_endpoints
}


# ==============================================================================
# HA CLOUD VPN EXAMPLE: OUTPUTS
# ==============================================================================

output "gateway_public_ips" {
  description = "Public IP addresses for GCP HA VPN Gateway interfaces (configure on remote edge firewall)."
  value       = module.ha_vpn.gateway_public_ips
}

output "gateways" {
  description = "Detailed map of provisioned HA VPN Gateways."
  value       = module.ha_vpn.gateways
}

output "external_gateways" {
  description = "Registered external on-premises peer gateways."
  value       = module.ha_vpn.external_gateways
}

output "tunnels" {
  description = "Provisioned IPsec VPN tunnels."
  value       = module.ha_vpn.tunnels
}

output "tunnel_ids" {
  description = "Resource IDs of the provisioned VPN tunnels."
  value       = module.ha_vpn.tunnel_ids
}

output "router_interfaces" {
  description = "Configured Cloud Router BGP interfaces."
  value       = module.ha_vpn.router_interfaces
}

output "router_peers" {
  description = "Configured Cloud Router eBGP peering sessions."
  value       = module.ha_vpn.router_peers
}

output "total_tunnels_count" {
  description = "Total number of active VPN tunnels provisioned."
  value       = module.ha_vpn.total_tunnels_count
}
