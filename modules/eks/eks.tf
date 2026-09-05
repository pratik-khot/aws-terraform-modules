# EKS control plane and its network configuration.
resource "aws_eks_cluster" "this" {
  name                          = var.cluster_name
  role_arn                      = aws_iam_role.eks_cluster.arn
  version                       = var.cluster_version
  bootstrap_self_managed_addons = false
  enabled_cluster_log_types     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  access_config {
    authentication_mode                         = var.auth_mode
    bootstrap_cluster_creator_admin_permissions = var.creator_admin_permissions
  }

  # Enable EKS Auto Mode compute only when requested.
  dynamic "compute_config" {
    for_each = var.eks_mode == "auto" ? [1] : []
    content {
      enabled       = true
      node_pools    = ["general-purpose"]
      node_role_arn = aws_iam_role.auto_node[0].arn
    }
  }

  # Enable EKS Auto Mode block storage only when requested.
  dynamic "storage_config" {
    for_each = var.eks_mode == "auto" ? [1] : []
    content {
      block_storage {
        enabled = true
      }
    }
  }

  # Enable EKS Auto Mode load balancing only when requested.
  dynamic "kubernetes_network_config" {
    for_each = var.eks_mode == "auto" ? [1] : []
    content {
      elastic_load_balancing {
        enabled = true
      }
    }
  }

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }



  depends_on = [aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSComputePolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSBlockStoragePolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSLoadBalancingPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSNetworkingPolicy,
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodeMinimalPolicy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryPullOnly
  ]

  tags = merge(local.common_tags, {
    cluster_name = var.cluster_name
    eks_mode     = var.eks_mode
  })

}





