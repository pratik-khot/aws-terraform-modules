variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string

}

variable "cluster_version" {
  description = "The Kubernetes version for the EKS cluster."
  type        = string
}

variable "node_group_scaling" {
  type = object({
    desired_size = number
    max_size     = number
    min_size     = number
  })
  default = {
    desired_size = 3
    max_size     = 5
    min_size     = 1
  }
}

variable "auth_mode" {
  description = "The authentication mode for the EKS cluster."
  type        = string

}

variable "region" {
  description = "The AWS region where the EKS cluster will be created."
  type        = string
}

variable "create_lbc_role" {
  type    = bool
  default = false
}

variable "create_external_dns_role" {
  type    = bool
  default = false
}

variable "external_dns_hosted_zone_arns" {
  type    = list(string)
  default = []
}

variable "create_secrets_store_provider_role" {
  type    = bool
  default = false
}

variable "secrets_manager_secret_arns" {
  type    = list(string)
  default = []
}

variable "secrets_manager_kms_key_arns" {
  type    = list(string)
  default = []
}

variable "node_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "node_disk_size" {
  type    = number
  default = 100
}