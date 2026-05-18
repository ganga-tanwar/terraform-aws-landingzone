output "instance_ids" {
  value       = { for name, instance in aws_instance.this : name => instance.id }
  description = "Migrated EC2 instance IDs."
}

output "security_group_id" {
  value       = aws_security_group.windows.id
  description = "Windows workload security group ID."
}
