# ---------------------------------------------------------------------------
# Standard node group resources
# Purpose: create the managed EC2 node groups used in standard EKS mode.
# ---------------------------------------------------------------------------

moved {
  from = aws_eks_node_group.this[0]
  to   = aws_eks_node_group.this["default"]
}

# Managed EC2 worker node groups for standard EKS mode.
resource "aws_eks_node_group" "this" {
  for_each        = var.eks_mode == "auto" ? {} : var.node_groups
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = each.key == "default" ? "${var.cluster_name}-node-group" : "${var.cluster_name}-${each.key}"
  node_role_arn   = aws_iam_role.node_group_role[0].arn
  subnet_ids      = var.subnet_ids
  version         = coalesce(each.value.version, var.cluster_version)
  instance_types  = each.value.instance_types
  disk_size       = each.value.disk_size
  capacity_type   = each.value.capacity_type
  labels          = each.value.labels

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }

  update_config {
    max_unavailable = 1
  }

  dynamic "taint" {
    for_each = each.value.taints

    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy[0],
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy[0],
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly[0],
  ]

  tags = merge(local.common_tags, {
    cluster_name = aws_eks_cluster.this.name
  })
}

# IAM role assumed by worker nodes.
resource "aws_iam_role" "node_group_role" {
  count = var.eks_mode == "auto" ? 0 : 1
  name  = "${var.cluster_name}-eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  count      = var.eks_mode == "auto" ? 0 : 1
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group_role[0].name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  count      = var.eks_mode == "auto" ? 0 : 1
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group_role[0].name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  count      = var.eks_mode == "auto" ? 0 : 1
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group_role[0].name
}