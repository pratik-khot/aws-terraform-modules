variable "region" {
  description = "AWS region for the example"
  type        = string
}

variable "ami_id" {
  description = "Existing AMI ID for the instance"
  type        = string
}

variable "subnet_id" {
  description = "Existing subnet ID for the instance"
  type        = string
}

variable "sg_ids" {
  description = "Security groups to attach to the instance"
  type        = list(string)
  default     = []
}

variable "app_name" {
  description = "Application name used in resource tags"
  type        = string
  default     = "demo-app"
}

variable "env" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}
