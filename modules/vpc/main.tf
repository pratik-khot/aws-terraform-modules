# VPC network container.
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  region           = var.region

  enable_dns_hostnames = true

  tags = merge(local.custom_tags, {
    Name = "${var.project_name}-vpc"
  })
}


# Internet gateway for public internet access.
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = merge(local.custom_tags, {
    Name = "${aws_vpc.main.tags.Name}-igw"
  })
}

# Public subnets for internet-facing resources.
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  for_each                = { for idx, az in local.azs : az => local.public_subnets[idx] }
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true

  tags = merge(local.custom_tags, {
    Name                     = "${aws_vpc.main.tags.Name}-pub-sub-${substr(split("-", each.key)[0], 0, 2)}${substr(split("-", each.key)[1], 0, 1)}${split("-", each.key)[2]}",
    "kubernetes.io/role/elb" = "1"
  })
}

# Private subnets for internal resources.

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  for_each          = { for idx, az in local.azs : az => local.private_subnets[idx] }
  cidr_block        = each.value
  availability_zone = each.key
  tags = merge(local.custom_tags, {
    Name                              = "${aws_vpc.main.tags.Name}-pvt-sub-${substr(split("-", each.key)[0], 0, 2)}${substr(split("-", each.key)[1], 0, 1)}${split("-", each.key)[2]}",
    "kubernetes.io/role/internal-elb" = "1"
  })
}

# Elastic IP used by the NAT gateway in zonal mode.
resource "aws_eip" "nat" {
  tags = merge(local.custom_tags, {
    Name = "${aws_vpc.main.tags.Name}-nat-eip"
  })

}


# NAT gateway for private subnet egress.
resource "aws_nat_gateway" "main" {
  availability_mode = var.nat_availability_mode
  connectivity_type = "public"
  allocation_id     = var.nat_availability_mode == "zonal" ? aws_eip.nat.id : null
  subnet_id         = var.nat_availability_mode == "zonal" ? values(aws_subnet.public)[0].id : null
  depends_on        = [aws_internet_gateway.main]
  tags = merge(local.custom_tags, {
    Name = "${aws_vpc.main.tags.Name}-nat-gw-${substr(var.nat_availability_mode, 0, 1)}"
  })
}


# Public route table sends internet traffic to the gateway.
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = merge(local.custom_tags, {
    Name = "${aws_vpc.main.tags.Name}-public-rt"
  })

}

# Associate public subnets with the public route table.
resource "aws_route_table_association" "public_rta" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}


# Private route table sends egress traffic through the NAT gateway.
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main.id
  }

  tags = merge(local.custom_tags, {
    Name = "${aws_vpc.main.tags.Name}-private-rt"
  })
}

# Associate private subnets with the private route table.
resource "aws_route_table_association" "private_rta" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt.id
}


# Optional security group for public access.
resource "aws_security_group" "default" {
  count       = var.default_sg_required ? 1 : 0
  name        = "${aws_vpc.main.tags.Name}-public-sg"
  description = "Default public security group for ${var.project_name}-${var.environment}"
  vpc_id      = aws_vpc.main.id

  tags = merge(local.custom_tags, {
    Name = "${aws_vpc.main.tags.Name}-public-sg"
  })
}

# Allow HTTP, HTTPS, and SSH ingress when the public group is enabled.
resource "aws_vpc_security_group_ingress_rule" "public" {
  for_each = { "allow http inbound from internet" = 80, "allow https inbound from internet" = 443, "allow ssh inbound from internet" = 22 }

  security_group_id = aws_security_group.default[0].id
  from_port         = each.value
  to_port           = each.value
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  description       = each.key
}

# Allow outbound traffic from the public security group.
resource "aws_vpc_security_group_egress_rule" "public" {
  security_group_id = aws_security_group.default[0].id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all outbound traffic"
}


### Flow Logs 

resource "aws_flow_log" "this" {
  iam_role_arn    = aws_iam_role.vpc_flow_logs_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name = "vpc-flow-logs"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "vpc_flow_logs_role" {
  name               = "vpc-flow-logs-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "vpc_flow_logs_policy" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "vpc_flow_logs_policy" {
  name   = "vpc-flow-logs-policy"
  role   = aws_iam_role.vpc_flow_logs_role.id
  policy = data.aws_iam_policy_document.vpc_flow_logs_policy.json
}