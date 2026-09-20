output "cluster_connection" {
  value = module.my-eks.eks_cluster_connection
}

output "cluster_arn" {
  value = module.my-eks.eks_cluster_arn
}

output "cluster_name" {
  value = module.my-eks.eks_cluster_name
}

output "cluster_endpoint" {
  value = module.my-eks.eks_cluster_endpoint
}