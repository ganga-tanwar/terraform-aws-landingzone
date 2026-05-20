output "customer_gateway_id" {
  value       = try(aws_customer_gateway.this[0].id, null)
  description = "Customer gateway ID when created."
}

output "vpn_connection_id" {
  value       = try(aws_vpn_connection.this[0].id, null)
  description = "VPN connection ID when created."
}

output "direct_connect_gateway_id" {
  value       = try(aws_dx_gateway.this[0].id, null)
  description = "Direct Connect Gateway ID when created."
}
