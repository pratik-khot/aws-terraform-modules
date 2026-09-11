module "my-eks" {
  source                             = "../../modules/eks"
  cluster_name                       = var.cluster_name
  auth_mode                          = var.auth_mode
  region                             = var.region
  cluster_version                    = var.cluster_version
  node_group_scaling                 = var.node_group_scaling
  node_instance_types                = var.node_instance_types
  node_disk_size                     = var.node_disk_size
  subnet_ids                         = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  create_lbc_role                    = var.create_lbc_role
  create_external_dns_role           = var.create_external_dns_role
  external_dns_hosted_zone_arns      = var.external_dns_hosted_zone_arns
  create_secrets_store_provider_role = var.create_secrets_store_provider_role
  secrets_manager_secret_arns        = var.secrets_manager_secret_arns
  secrets_manager_kms_key_arns       = var.secrets_manager_kms_key_arns
}