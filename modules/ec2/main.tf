# Primary EC2 instance.
resource "aws_instance" "this" {

  ami                         = var.ami_id
  instance_type               = var.instance_type
  availability_zone           = var.availability_zone
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.sg_ids
  associate_public_ip_address = var.enable_public_ip
  private_ip                  = var.private_ip
  key_name                    = var.key_name
  iam_instance_profile        = var.iam_instance_profile
  disable_api_termination     = var.disable_api_termination
  disable_api_stop            = var.disable_api_stop
  monitoring                  = var.enable_monitoring
  ebs_optimized               = var.ebs_optimized
  user_data                   = var.user_data
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"

  }


  # Root disk attached to the instance.
  root_block_device {
    volume_size           = var.root_volume_specs.size
    volume_type           = var.root_volume_specs.type
    delete_on_termination = var.root_volume_specs.delete_on_termination
    encrypted             = true
    kms_key_id            = var.root_volume_specs.kms_key_id
    tags = merge(
      local.default_tags,
      {
        Name = "${var.app_name}-${var.env}-${var.instance_no}"
      },
      var.tags
    )
  }

  tags = merge(
    local.default_tags,
    {
      Name          = "${var.app_name}-${var.env}-${var.instance_no}",
      instance_name = aws_instance.this.tags["Name"]
    },
    var.tags
  )
}

# Optional data disks created for the instance.
resource "aws_ebs_volume" "this" {
  for_each = var.data_volume_specs

  availability_zone = aws_instance.this.availability_zone
  size              = each.value.size
  type              = each.value.type
  encrypted         = true
  kms_key_id        = coalesce(each.value.kms_key_id, data.aws_kms_alias.ebs.target_key_arn)
  iops              = each.value.iops
  throughput        = each.value.throughput

  tags = merge(
    local.default_tags,
    {
      Name          = "${var.app_name}-${var.env}-${each.key}",
      instance_name = aws_instance.this.tags["Name"]
    }
  )
}

# Attach each data disk to the instance.
resource "aws_volume_attachment" "this" {
  for_each = var.data_volume_specs

  device_name = each.value.device_name
  instance_id = aws_instance.this.id
  volume_id   = aws_ebs_volume.this[each.key].id
}

