# Module outputs expose values to the calling configuration.
output "instance_id" {
  description = "The EC2 instance ID"
  value       = aws_instance.this.id
}

output "instance_private_ip" {
  description = "The EC2 instance private IP"
  value       = aws_instance.this.private_ip
}

output "instance_public_ip" {
  description = "The EC2 instance public IP"
  value       = aws_instance.this.public_ip
}

output "attached_ebs_volume_ids" {
  description = "Map of attached EBS volume IDs keyed by logical volume name"
  value       = { for name, volume in aws_ebs_volume.this : name => volume.id }
}