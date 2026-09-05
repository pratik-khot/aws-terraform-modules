locals {
  # Shared tags applied to EC2 resources.
  default_tags = {
    ManagedBy   = "Terraform"
    Environment = var.env
    Application = var.app_name
  }

}

data "aws_kms_alias" "ebs" {
  name = "alias/aws/ebs"
}

