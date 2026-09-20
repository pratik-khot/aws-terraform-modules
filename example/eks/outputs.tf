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

output "karpenter_controller_role_arn" {
  value = module.my-eks.karpenter_controller_role_arn
}

output "karpenter_node_role_arn" {
  value = module.my-eks.karpenter_node_role_arn
}

output "karpenter_node_instance_profile_name" {
  value = module.my-eks.karpenter_node_instance_profile_name
}

output "karpenter_interruption_queue_arn" {
  value = module.my-eks.karpenter_interruption_queue_arn
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