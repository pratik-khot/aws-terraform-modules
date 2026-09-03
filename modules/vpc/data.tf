# Data sources discover the AWS availability zones used by this module.
data "aws_availability_zones" "available" {
  state = "available"
}