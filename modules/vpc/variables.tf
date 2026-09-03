variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of availability zones to use"
  type        = number
  default     = 3
}

variable "subnet_newbits" {
  description = "The number of new bits to use for subnetting"
  type        = number
  default     = 8
}

variable "region" {
  description = "The AWS region to create resources in"
  type        = string
  default     = "us-east-1"
}

variable "nat_availability_mode" {
  description = "NAT gateway availability mode"
  type        = string
  default     = "zonal"

  validation {
    condition     = contains(["zonal", "regional"], var.nat_availability_mode)
    error_message = "Valid values are zonal or regional."
  }
}

variable "environment" {
  description = "The environment for the VPC (dev, prod, test)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "Infra"
}

variable "project_owner" {
  description = "The owner of the project"
  type        = string
  default     = "Infra Team"
}

variable "default_sg_required" {
  description = "Whether to create a default public security group to allow all traffic within the VPC"
  type        = bool
  default     = true
}

variable "log_group_kms_key_arn" {
  type    = string
  default = null
}

variable "log_group_retention_in_days" {
  type    = number
  default = 365
}