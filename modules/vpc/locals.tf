locals {
  # Availability zones and CIDR ranges used by the subnet resources.
  azs             = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  public_subnets  = [for k, az in local.azs : cidrsubnet(var.vpc_cidr, var.subnet_newbits, k)]
  private_subnets = [for k, az in local.azs : cidrsubnet(var.vpc_cidr, var.subnet_newbits, k + 10)]


  # Base tags shared by all VPC resources.
  default_tags = {
    managed_by    = "terraform"
    project_name  = var.project_name
    project_owner = var.project_owner

  }

  # Environment-specific tag values.
  env_tags = {
    dev = {
      environment = "dev"
      Backup      = "false"
    },
    prod = {
      environment = "prod"
      Backup      = "true"
    },
    test = {
      environment = "test"
      Backup      = "false"
    }
  }

  # Combine base and environment-specific tags.
  custom_tags = merge(local.default_tags, lookup(local.env_tags, var.environment, {}))
}

