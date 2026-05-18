output "vpc_id" {
  value       = aws_vpc.this.id
  description = "VPC ID."
}

output "vpc_cidr" {
  value       = aws_vpc.this.cidr_block
  description = "VPC CIDR."
}

output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "Public subnet IDs."
}

output "app_subnet_ids" {
  value       = aws_subnet.app[*].id
  description = "Application subnet IDs."
}

output "db_subnet_ids" {
  value       = aws_subnet.db[*].id
  description = "Database subnet IDs."
}

output "workload_security_group_id" {
  value       = aws_security_group.workload.id
  description = "Default workload security group ID."
}

output "transit_gateway_attachment_id" {
  value       = try(aws_ec2_transit_gateway_vpc_attachment.this[0].id, null)
  description = "Transit Gateway attachment ID."
}

output "private_route_table_ids" {
  value       = aws_route_table.private[*].id
  description = "Private route table IDs."
}
