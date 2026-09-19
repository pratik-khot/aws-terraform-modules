# ---------------------------------------------------------------------------
# VPC module data sources
# Purpose: discover the AWS AZs available for subnet placement.
# ---------------------------------------------------------------------------
data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "zone-name"
    values = var.availability_zone_names
  }
}