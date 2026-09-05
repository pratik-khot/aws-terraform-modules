output "cluster_connection" {
  description = "Command to update kubeconfig for the EKS cluster."
  value       = "aws eks update-kubeconfig --name ${aws_eks_cluster.this.name} --region ${var.region}"
}

output "cluster_arn" {
  description = "ARN of cluster"
  value       = aws_eks_cluster.this.arn

}

output "cluster_sgs" {
  description = "Cluster security groups"
  value       = aws_eks_cluster.this.vpc_config[0].security_group_ids

}