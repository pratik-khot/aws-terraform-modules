# Optional Fargate profile for pods in the selected namespace.
resource "aws_eks_fargate_profile" "this" {
  count                  = var.enable_fargate ? 1 : 0
  cluster_name           = aws_eks_cluster.this.name
  fargate_profile_name   = "${aws_eks_cluster.this.name}-farget-prf"
  pod_execution_role_arn = aws_iam_role.fargate[0].arn
  subnet_ids             = var.subnet_ids

  selector {
    namespace = var.fargate_namespace
  }

  tags = merge(local.common_tags, {
    cluster_name = aws_eks_cluster.this.name
  })

}

# Pod execution role used by the Fargate profile.
resource "aws_iam_role" "fargate" {
  count = var.enable_fargate ? 1 : 0
  name  = "${aws_eks_cluster.this.name}-fargate-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSFargatePodExecutionRolePolicy" {
  count      = var.enable_fargate ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate[0].name
}