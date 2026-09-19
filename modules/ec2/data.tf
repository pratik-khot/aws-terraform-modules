# ---------------------------------------------------------------------------
# EC2 module data sources
# Purpose: resolve the default EBS KMS key alias used for encrypted volumes.
# ---------------------------------------------------------------------------
data "aws_kms_alias" "ebs" {
  name = "alias/aws/ebs"
}