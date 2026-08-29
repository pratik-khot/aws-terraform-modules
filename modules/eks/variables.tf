variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs for the EKS cluster."
  type        = list(string)
}

variable "region" {
  description = "The AWS region where the EKS cluster will be created."
  type        = string
}

variable "creator_admin_permissions" {
  description = "Whether to grant admin permissions to the cluster creator."
  type        = bool
  default     = true
}

variable "auth_mode" {
  description = "The authentication mode for the EKS cluster."
  type        = string
  default     = "API_AND_CONFIG_MAP"

  validation {
    condition     = contains(["API_AND_CONFIG_MAP", "API", "CONFIG_MAP"], var.auth_mode)
    error_message = "auth_mode must be either 'API_AND_CONFIG_MAP', 'API', or 'CONFIG_MAP'."
  }
}

variable "eks_mode" {
  type    = string
  default = "managed"

  validation {
    condition     = var.eks_mode == "managed" || var.eks_mode == "auto"
    error_message = "eks_mode must be either 'managed_mode' or 'auto_mode'."
  }
}

variable "enable_fargate" {
  type    = bool
  default = false
}
variable "fargate_namespace" {
  default = "default"
}

variable "addons" {
  type = list(string)

  default = [
    "coredns",
    "kube-proxy",
    "vpc-cni",
    "eks-pod-identity-agent",
    "aws-ebs-csi-driver"
  ]
}