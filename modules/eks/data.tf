# Trust policy used by EKS pod identity roles.
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}


# Resolve the latest compatible version for each enabled addon.
data "aws_eks_addon_version" "addon_versions" {
  for_each           = local.addons
  addon_name         = each.key
  kubernetes_version = aws_eks_cluster.this.version

  most_recent = true
}
