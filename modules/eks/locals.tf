locals {

  # Tags shared by resources in this EKS module.
  common_tags = {
    managed_by = "terraform"

  }

  # Select AWS-managed addons based on the EKS operating mode.
  default_addons = var.eks_mode == "auto" ? {
    eks-pod-identity-agent = {}
    } : {
    coredns                = {}
    kube-proxy             = {}
    vpc-cni                = {}
    eks-pod-identity-agent = {}
    aws-ebs-csi-driver     = {}
  }

  # Caller-provided addon settings override the defaults.
  addons = merge(local.default_addons, var.addons)

  has_vpc_cni = try(local.addons["vpc-cni"], null) != null
  has_ebs_csi = try(local.addons["aws-ebs-csi-driver"], null) != null

}
