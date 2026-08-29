resource "aws_eks_addon" "addons" {
  for_each = toset(var.addons)

  cluster_name = aws_eks_cluster.this.name
  addon_name   = each.value

  tags = local.common_tags
}


resource "aws_iam_role" "vpc_cni" {
  count = contains(var.addons, "vpc-cni") ? 1 : 0
  name  = "${aws_eks_cluster.this.name}-vpc-cni-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "sts:AssumeRole",
        "sts:TagSession"
      ]

      Principal = {
        Service = "pods.eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "vpc_cni" {
  count      = contains(var.addons, "vpc-cni") ? 1 : 0
  role       = aws_iam_role.vpc_cni[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_eks_pod_identity_association" "vpc_cni" {
  count           = contains(var.addons, "vpc-cni") ? 1 : 0
  cluster_name    = aws_eks_cluster.this.name
  namespace       = "kube-system"
  service_account = "aws-node"
  role_arn        = aws_iam_role.vpc_cni[0].arn
}

resource "aws_iam_role" "ebs_csi" {
  count = contains(var.addons, "aws-ebs-csi-driver") ? 1 : 0
  name  = "${aws_eks_cluster.this.name}-ebs-csi-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "sts:AssumeRole",
        "sts:TagSession"
      ]

      Principal = {
        Service = "pods.eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  count      = contains(var.addons, "aws-ebs-csi-driver") ? 1 : 0
  role       = aws_iam_role.ebs_csi[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_eks_pod_identity_association" "ebs_csi" {
  count           = contains(var.addons, "aws-ebs-csi-driver") ? 1 : 0
  cluster_name    = aws_eks_cluster.this.name
  namespace       = "kube-system"
  service_account = "aws-node"
  role_arn        = aws_iam_role.ebs_csi[0].arn
}

