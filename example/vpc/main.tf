module "vpc" {
  source                = "../../modules/vpc"
  vpc_cidr              = var.vpc_cidr
  az_count              = var.az_count
  subnet_newbits        = var.subnet_newbits
  default_sg_required   = var.default_sg_required
  project_name          = var.project_name
  project_owner         = var.project_owner
  nat_availability_mode = var.nat_availability_mode




}