variable "ami_id" {
  description = "AMI ID to use for the EC2 instance"
  type        = string
  default     = null
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "private_ip" {
  description = "Private IP address to assign to the instance"
  type        = string
  default     = null
}

variable "instance_no" {
  description = "Instance number used for naming and tagging"
  type        = number
  default     = 1
}

variable "availability_zone" {
  description = "Availability zone for the EC2 instance"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Subnet ID where the instance will be launched"
  type        = string
  default     = null
}

variable "sg_ids" {
  description = "Security group IDs to attach to each EC2 instance"
  type        = list(string)
  default     = []
}

variable "enable_public_ip" {
  description = "Whether to assign a public IP to the instance"
  type        = bool
  default     = false
}

variable "key_name" {
  description = "Name of the EC2 key pair to attach"
  type        = string
  default     = null
}

variable "enable_monitoring" {
  description = "Whether to enable detailed monitoring"
  type        = bool
  default     = true
}

variable "ebs_optimized" {
  description = "Whether to enable EBS optimization"
  type        = bool
  default     = false
}

variable "user_data" {
  description = "User data script for instance bootstrap"
  type        = string
  default     = null
}


variable "tags" {
  description = "Additional tags to attach to the instance"
  type        = map(string)
  default     = {}
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

variable "disable_api_termination" {
  description = "Disable API termination for the instance"
  type        = bool
  default     = false
}

variable "disable_api_stop" {
  description = "Disable API stop for the instance"
  type        = bool
  default     = false
}

variable "root_volume_specs" {
  description = "Root volume specifications for the instance"
  type = object({
    size                  = number
    type                  = optional(string, "gp3")
    delete_on_termination = bool
    encrypted             = optional(bool, true)
    kms_key_id            = optional(string)
  })

  default = {
    size                  = 20
    type                  = "gp3"
    delete_on_termination = true
    encrypted             = true
  }
}

variable "data_volume_specs" {
  description = "Optional additional EBS volume definitions keyed by logical name. This is only used when you want to define volumes outside the instance block."
  type = map(object({
    instance_key          = optional(string)
    size                  = number
    type                  = optional(string, "gp3")
    delete_on_termination = optional(bool, true)
    encrypted             = optional(bool, true)
    device_name           = string
    kms_key_id            = optional(string)
    iops                  = optional(number)
    throughput            = optional(number)
  }))

  default = {}
}

variable "iam_instance_profile" {
  description = "IAM instance profile to attach to every instance, when a specific instance does not define one"
  type        = string
  default     = null
}