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
  value       = aws_eks_cluster.this.vpc_config[0].security_group_id

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