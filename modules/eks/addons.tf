
# Install and configure the enabled EKS managed addons.
resource "aws_eks_addon" "addons" {
  for_each = local.addons

  cluster_name  = var.cluster_name
  addon_name    = each.key
  addon_version = coalesce(try(each.value.version, null), data.aws_eks_addon_version.addon_versions[each.key].version)

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_cluster.this,
    aws_eks_pod_identity_association.vpc_cni,
    aws_eks_pod_identity_association.ebs_csi
  ]
}





