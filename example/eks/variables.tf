variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string

}

variable "cluster_version" {
  description = "The Kubernetes version for the EKS cluster."
  type        = string
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