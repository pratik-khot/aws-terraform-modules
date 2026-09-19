# ---------------------------------------------------------------------------
# EC2 module locals
# Purpose: define common tags applied to EC2 instances and attached storage.
# ---------------------------------------------------------------------------
locals {
  # Shared tags applied to EC2 resources.
  default_tags = {
    ManagedBy   = "Terraform"
    Environment = var.env
    Application = var.app_name
  }

}



