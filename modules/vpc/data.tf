# ---------------------------------------------------------------------------
# VPC module data sources
# Purpose: discover the AWS AZs available for subnet placement.
# ---------------------------------------------------------------------------
data "aws_availability_zones" "available" {
  state = "available"
}