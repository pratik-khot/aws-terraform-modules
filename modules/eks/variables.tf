variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}

variable "cluster_version" {
  description = "The Kubernetes version for the EKS cluster."
  type        = string
  default     = "1.36"
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
  default = "standard"

  validation {
    condition     = contains(["standard", "auto"], var.eks_mode)
    error_message = "eks_mode must be either 'standard' or 'auto'."
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
  type    = map(any)
  default = {}
}

variable "create_lbc_role" {
  description = "Whether to create an IAM role,policy,PIA for the AWS Load Balancer Controller"
  type        = bool
  default     = false
}