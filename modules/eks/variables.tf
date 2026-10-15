# ---------------------------------------------------------------------------
# EKS module variables
# Purpose: define the inputs used to configure the EKS cluster, IAM, and addons.
# ---------------------------------------------------------------------------
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

variable "node_groups" {
  description = "Map of EKS managed node groups to create in standard mode. Omit this input to create the default node group."
  type = map(object({
    version        = optional(string)
    instance_types = optional(list(string), ["t3.medium"])
    disk_size      = optional(number, 100)
    capacity_type  = optional(string, "ON_DEMAND")
    desired_size   = optional(number, 3)
    max_size       = optional(number, 5)
    min_size       = optional(number, 1)
    labels         = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = optional(string)
      effect = string
    })), [])
  }))
  default = {
    default = {}
  }

  validation {
    condition = alltrue([
      for node_group in values(var.node_groups) :
      node_group.min_size >= 0 &&
      node_group.min_size <= node_group.desired_size &&
      node_group.desired_size <= node_group.max_size
    ])
    error_message = "Each node group must satisfy min_size >= 0, min_size <= desired_size, and desired_size <= max_size."
  }

  validation {
    condition = alltrue([
      for node_group in values(var.node_groups) :
      contains(["ON_DEMAND", "SPOT"], node_group.capacity_type)
    ])
    error_message = "Each node group capacity_type must be either ON_DEMAND or SPOT."
  }

  validation {
    condition = alltrue(flatten([
      for node_group in values(var.node_groups) : [
        for taint in node_group.taints :
        contains(["NO_SCHEDULE", "NO_EXECUTE", "PREFER_NO_SCHEDULE"], taint.effect)
      ]
    ]))
    error_message = "Each taint effect must be NO_SCHEDULE, NO_EXECUTE, or PREFER_NO_SCHEDULE."
  }
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

variable "create_external_dns_role" {
  description = "Whether to create the IAM role, policy, and Pod Identity association for ExternalDNS."
  type        = bool
  default     = false
}

variable "external_dns_hosted_zone_arns" {
  description = "Route 53 hosted-zone ARNs that ExternalDNS may manage."
  type        = list(string)
  default     = []
}

variable "create_secrets_store_provider_role" {
  description = "Whether to create the IAM role, policy, and Pod Identity association for the AWS Secrets Store CSI provider."
  type        = bool
  default     = false
}

variable "secrets_manager_secret_arns" {
  description = "Secrets Manager secret ARNs that the AWS Secrets Store CSI provider may read."
  type        = list(string)
  default     = []
}

variable "secrets_manager_kms_key_arns" {
  description = "KMS key ARNs that the AWS Secrets Store CSI provider may use for decrypting secrets."
  type        = list(string)
  default     = []
}

variable "use_karpenter" {
  description = "Whether to create the IAM roles for Karpenter."
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to apply to all resources in the EKS module."
  type        = map(string)
  default     = {}
}