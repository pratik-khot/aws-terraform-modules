variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "az_count" {
  description = "Number of availability zones to use"
  type        = number
}

variable "subnet_newbits" {
  description = "The number of new bits to use for subnetting"
  type        = number
}

variable "region" {
  description = "The AWS region to create resources in"
  type        = string
}

variable "nat_availability_mode" {
  description = "NAT gateway availability mode"
  type        = string
}

variable "environment" {
  description = "The environment for the VPC (dev, prod, test)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "project_owner" {
  description = "The owner of the project"
  type        = string
}

variable "default_sg_required" {
  description = "Whether to create a default public security group to allow all traffic within the VPC"
  type        = bool
}