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