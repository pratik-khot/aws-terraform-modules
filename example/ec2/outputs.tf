output "instance_id" {
  value = module.ec2.instance_id
}

output "instance_private_ip" {
  value = module.ec2.instance_private_ip
}

output "instance_public_ip" {
  value = module.ec2.instance_public_ip
}

output "attached_ebs_volume_ids" {
  value = module.ec2.attached_ebs_volume_ids
}
