module "networking" {
  source           = "git::https://github.com/yuva-cloud-devops/gcp-terraform-custom-modules.git//networking-infrastructure/vpc-subnet-router-nat-firewall?ref=main"
  config_file_path = "${path.module}/network-config.yaml"
}

# 2. DYNAMIC YAML-DRIVEN SHARED VPC
module "shared_vpc" {
  source           = "git::https://github.com/yuva-cloud-devops/gcp-terraform-custom-modules.git//networking-infrastructure/shared-vpc?ref=main"
  yaml_config_path = "${path.module}/shared_vpc.yaml"

  # Ensures base subnets exist before attempting IAM attachments
  depends_on = [module.networking]
}

module "hierarchical_firewalls" {
  source           = "git::https://github.com/yuva-cloud-devops/gcp-terraform-custom-modules.git//networking-infrastructure/hierarchical-firewalls?ref=main"
  yaml_config_path = "${path.module}/firewalls.yaml"
}
