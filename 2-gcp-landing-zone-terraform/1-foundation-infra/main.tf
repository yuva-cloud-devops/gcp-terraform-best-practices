

module "foundation_infrastructure" {
  source           = "git::https://github.com/yuva-cloud-devops/gcp-terraform-custom-modules.git//foundation-infrastructure?ref=main"
  yaml_config_path = "${path.module}/foundation.yaml"
}
