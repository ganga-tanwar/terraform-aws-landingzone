output "inbound_resolver_endpoint_id" {
  value       = aws_route53_resolver_endpoint.inbound.id
  description = "Inbound resolver endpoint ID."
}

output "outbound_resolver_endpoint_id" {
  value       = aws_route53_resolver_endpoint.outbound.id
  description = "Outbound resolver endpoint ID."
}

output "vpn_connection_id" {
  value       = try(aws_vpn_connection.this[0].id, null)
  description = "VPN connection ID when created."
}

output "direct_connect_gateway_id" {
  value       = aws_dx_gateway.this.id
  description = "Direct Connect Gateway ID."
}
