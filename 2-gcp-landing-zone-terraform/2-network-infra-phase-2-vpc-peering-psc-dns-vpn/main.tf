module "networking" {
  source           = "git::https://github.com/yuva-cloud-devops/gcp-terraform-custom-modules.git//networking-infrastructure/vpc-subnet-router-nat-firewall?ref=main"
  config_file_path = "${path.module}/network.yaml"
}


# ------------------------------------------------------------------------------
# 2. VPC Network Peering Custom Module Instantiation
# ------------------------------------------------------------------------------
module "vpc_peering" {
  source                  = "git::https://github.com/yuva-cloud-devops/gcp-terraform-custom-modules.git//networking-infrastructure/network-peering?ref=main"
  yaml_config_path        = "${path.module}/peering.yaml"
  local_network_self_link = module.networking.vpc_self_links["vpc-hub"]

  # Dynamically link the newly provisioned sub VPC
  peer_network_overrides = {
    "peering-hub-to-sub" = module.networking.vpc_self_links["vpc-sub"]
  }

  depends_on = [module.networking]
}


# ------------------------------------------------------------------------------
# 3. Cloud DNS Custom Module Instantiation
# ------------------------------------------------------------------------------
module "cloud_dns" {
  source           = "git::https://github.com/yuva-cloud-devops/gcp-terraform-custom-modules.git//networking-infrastructure/cloud-dns?ref=main"
  yaml_config_path = "${path.module}/dns.yaml"
  network_self_links = [
    module.networking.vpc_self_links["vpc-hub"],
    module.networking.vpc_self_links["vpc-sub"]
  ]

  depends_on = [module.networking, module.vpc_peering]
}


# ------------------------------------------------------------------------------
# 4. Private Service Connect (PSC) Custom Module Instantiation
# ------------------------------------------------------------------------------
module "psc" {
  source            = "git::https://github.com/yuva-cloud-devops/gcp-terraform-custom-modules.git//networking-infrastructure/private-service-connect?ref=main"
  yaml_config_path  = "${path.module}/psc.yaml"
  network_self_link = module.networking.vpc_self_links["vpc-hub"]

  depends_on = [module.networking]
}



# ------------------------------------------------------------------------------
# 5. Cloud HA VPN Custom Module Instantiation
# ------------------------------------------------------------------------------
module "ha_vpn" {
  source            = "git::https://github.com/yuva-cloud-devops/gcp-terraform-custom-modules.git//networking-infrastructure/ha-cloud-vpn?ref=main"
  yaml_config_path  = "${path.module}/vpn.yaml"
  network_self_link = module.networking.vpc_self_links["vpc-hub"]
  router_name       = module.networking.routers["router-hub"].name

  depends_on = [module.networking]
}
