# IAM role assumed by the EKS control plane.
resource "aws_iam_role" "eks_cluster" {
  name = "${var.cluster_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}


# Required control-plane permissions.
resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSComputePolicy" {
  count      = var.eks_mode == "auto" ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSComputePolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSBlockStoragePolicy" {
  count      = var.eks_mode == "auto" ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSLoadBalancingPolicy" {
  count      = var.eks_mode == "auto" ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSNetworkingPolicy" {
  count      = var.eks_mode == "auto" ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy"
  role       = aws_iam_role.eks_cluster.name
}



# IAM role used by EKS Auto Mode node pools.
resource "aws_iam_role" "auto_node" {
  count = var.eks_mode == "auto" ? 1 : 0
  name  = "${var.cluster_name}-eks-auto-node-pool-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodeMinimalPolicy" {
  count      = var.eks_mode == "auto" ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodeMinimalPolicy"
  role       = aws_iam_role.auto_node[0].name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryPullOnly" {
  count      = var.eks_mode == "auto" ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  role       = aws_iam_role.auto_node[0].name
}




# Pod identity role for the VPC CNI addon.
resource "aws_iam_role" "vpc_cni" {
  count              = local.has_vpc_cni ? 1 : 0
  name               = "${aws_eks_cluster.this.name}-vpc-cni-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "vpc_cni" {
  count      = local.has_vpc_cni ? 1 : 0
  role       = aws_iam_role.vpc_cni[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_eks_pod_identity_association" "vpc_cni" {
  count           = local.has_vpc_cni ? 1 : 0
  cluster_name    = aws_eks_cluster.this.name
  namespace       = "kube-system"
  service_account = "aws-node"
  role_arn        = aws_iam_role.vpc_cni[0].arn

  depends_on = [aws_iam_role_policy_attachment.vpc_cni]
}

# Pod identity role for the EBS CSI addon.
resource "aws_iam_role" "ebs_csi" {
  count = local.has_ebs_csi ? 1 : 0
  name  = "${aws_eks_cluster.this.name}-ebs-csi-role"

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  count      = local.has_ebs_csi ? 1 : 0
  role       = aws_iam_role.ebs_csi[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_eks_pod_identity_association" "ebs_csi" {
  count           = local.has_ebs_csi ? 1 : 0
  cluster_name    = aws_eks_cluster.this.name
  namespace       = "kube-system"
  service_account = "ebs-csi-controller-sa"
  role_arn        = aws_iam_role.ebs_csi[0].arn

  depends_on = [aws_iam_role_policy_attachment.ebs_csi]
}

# Optional pod identity role for the AWS Load Balancer Controller.
resource "aws_iam_role" "load_balancer_controller" {
  count              = var.create_lbc_role && var.eks_mode != "auto" ? 1 : 0
  name               = "${aws_eks_cluster.this.name}-load-balancer-controller-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_policy" "load_balancer_controller_policy" {
  count       = var.create_lbc_role && var.eks_mode != "auto" ? 1 : 0
  name        = "${aws_eks_cluster.this.name}-load-balancer-controller-policy"
  description = "Policy for the AWS Load Balancer Controller"
  policy      = file("${path.module}/lbc_iam_policy.json")
}

resource "aws_iam_role_policy_attachment" "lbc_policy_attachment" {
  count      = var.create_lbc_role && var.eks_mode != "auto" ? 1 : 0
  role       = aws_iam_role.load_balancer_controller[0].name
  policy_arn = aws_iam_policy.load_balancer_controller_policy[0].arn
}

resource "aws_eks_pod_identity_association" "lbc_pia" {
  count           = var.create_lbc_role && var.eks_mode != "auto" ? 1 : 0
  cluster_name    = aws_eks_cluster.this.name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.load_balancer_controller[0].arn

  depends_on = [aws_iam_role_policy_attachment.lbc_policy_attachment]
}