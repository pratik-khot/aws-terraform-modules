locals {
  # Shared tags applied to EC2 resources.
  default_tags = {
    ManagedBy   = "Terraform"
    Environment = var.env
    Application = var.app_name
  }

}



