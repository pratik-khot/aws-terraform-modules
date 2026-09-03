module "my-eks" {
  source          = "../../modules/eks"
  cluster_name    = var.cluster_name
  auth_mode       = var.auth_mode
  region          = var.region
  cluster_version = var.cluster_version
  subnet_ids      = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  create_lbc_role = var.create_lbc_role
}