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

output "cluster_security_groups" {
  value = module.my-eks.eks_cluster_sgs
}

output "cluster_certificate_authority_data" {
  value     = module.my-eks.eks_cluster_certificate_authority_data
  sensitive = true
}

output "node_group_arns" {
  value = module.my-eks.eks_node_group_arns
}

output "load_balancer_controller_role_arn" {
  value = module.my-eks.load_balancer_controller_role_arn
}

output "load_balancer_controller_pod_identity_association_id" {
  value = module.my-eks.load_balancer_controller_pod_identity_association_id
}

output "vpc_cni_role_arn" {
  value = module.my-eks.vpc_cni_role_arn
}

output "ebs_csi_role_arn" {
  value = module.my-eks.ebs_csi_role_arn
}

output "external_dns_role_arn" {
  value = module.my-eks.external_dns_role_arn
}

output "external_dns_pod_identity_association_id" {
  value = module.my-eks.external_dns_pod_identity_association_id
}

output "secrets_store_provider_role_arn" {
  value = module.my-eks.secrets_store_provider_role_arn
}

output "secrets_store_provider_pod_identity_association_id" {
  value = module.my-eks.secrets_store_provider_pod_identity_association_id
}

output "karpenter_controller_role_arn" {
  value = module.my-eks.karpenter_controller_role_arn
}

output "karpenter_controller_policy_arn" {
  value = module.my-eks.karpenter_controller_policy_arn
}

output "karpenter_controller_pod_identity_association_id" {
  value = module.my-eks.karpenter_controller_pod_identity_association_id
}

output "karpenter_node_role_arn" {
  value = module.my-eks.karpenter_node_role_arn
}

output "karpenter_node_instance_profile_name" {
  value = module.my-eks.karpenter_node_instance_profile_name
}

output "karpenter_node_instance_profile_arn" {
  value = module.my-eks.karpenter_node_instance_profile_arn
}

output "karpenter_interruption_queue_arn" {
  value = module.my-eks.karpenter_interruption_queue_arn
}

output "karpenter_interruption_queue_url" {
  value = module.my-eks.karpenter_interruption_queue_url
}

output "karpenter_health_event_rule_arn" {
  value = module.my-eks.karpenter_health_event_rule_arn
}

output "karpenter_spot_interrupt_rule_arn" {
  value = module.my-eks.karpenter_spot_interrupt_rule_arn
}

output "karpenter_rebalance_rule_arn" {
  value = module.my-eks.karpenter_rebalance_rule_arn
}

output "karpenter_instance_state_rule_arn" {
  value = module.my-eks.karpenter_instance_state_rule_arn
}