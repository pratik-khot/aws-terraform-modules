output "eks_cluster_connection" {
  description = "Command to update kubeconfig for the EKS cluster."
  value       = "aws eks update-kubeconfig --name ${aws_eks_cluster.this.name} --region ${var.region}"
}

output "eks_cluster_arn" {
  description = "ARN of cluster"
  value       = aws_eks_cluster.this.arn

}

output "eks_cluster_sgs" {
  description = "Cluster security groups"
  value = {
    cluster_security_group_id = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
    additional_sgs            = aws_eks_cluster.this.vpc_config[0].security_group_ids
  }

}


output "eks_cluster_endpoint" {
  description = "cluster endpoint"
  value       = aws_eks_cluster.this.endpoint

}

output "eks_cluster_certificate_authority_data" {
  value = aws_eks_cluster.this.certificate_authority[0].data
}

output "eks_cluster_name" {
  value = aws_eks_cluster.this.name
}

output "load_balancer_controller_role_arn" {
  description = "IAM role ARN used by the AWS Load Balancer Controller."
  value       = try(aws_iam_role.load_balancer_controller[0].arn, null)
}

output "vpc_cni_role_arn" {
  description = "IAM role ARN used by the VPC CNI Pod Identity association."
  value       = try(aws_iam_role.vpc_cni[0].arn, null)
}

output "ebs_csi_role_arn" {
  description = "IAM role ARN used by the EBS CSI Pod Identity association."
  value       = try(aws_iam_role.ebs_csi[0].arn, null)
}

output "load_balancer_controller_pod_identity_association_id" {
  description = "Pod Identity association ID for the AWS Load Balancer Controller."
  value       = try(aws_eks_pod_identity_association.lbc_pia[0].id, null)
}

output "external_dns_role_arn" {
  description = "IAM role ARN used by the ExternalDNS Pod Identity association."
  value       = try(aws_iam_role.external_dns[0].arn, null)
}

output "external_dns_pod_identity_association_id" {
  description = "Pod Identity association ID for ExternalDNS."
  value       = try(aws_eks_pod_identity_association.external_dns[0].id, null)
}

output "secrets_store_provider_role_arn" {
  description = "IAM role ARN used by the AWS Secrets Store CSI provider Pod Identity association."
  value       = try(aws_iam_role.secrets_store_provider[0].arn, null)
}

output "secrets_store_provider_pod_identity_association_id" {
  description = "Pod Identity association ID for the AWS Secrets Store CSI provider."
  value       = try(aws_eks_pod_identity_association.secrets_store_provider[0].id, null)
}