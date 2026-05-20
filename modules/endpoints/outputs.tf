output "gateway_endpoint_ids" {
  value       = { for service, endpoint in aws_vpc_endpoint.gateway : service => endpoint.id }
  description = "Gateway VPC endpoint IDs by service."
}

output "interface_endpoint_ids" {
  value       = { for service, endpoint in aws_vpc_endpoint.interface : service => endpoint.id }
  description = "Interface VPC endpoint IDs by service."
}
