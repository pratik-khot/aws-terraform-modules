# ---------------------------------------------------------------------------
# VPC module version constraints
# Purpose: declare the Terraform and AWS provider versions required for this module.
# ---------------------------------------------------------------------------
terraform {
  required_version = ">= 1.9.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}