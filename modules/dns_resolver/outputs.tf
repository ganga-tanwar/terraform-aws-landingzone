output "security_group_id" {
  value       = aws_security_group.resolver.id
  description = "Route 53 Resolver endpoint security group ID."
}

output "inbound_resolver_endpoint_id" {
  value       = aws_route53_resolver_endpoint.inbound.id
  description = "Inbound resolver endpoint ID."
}

output "outbound_resolver_endpoint_id" {
  value       = aws_route53_resolver_endpoint.outbound.id
  description = "Outbound resolver endpoint ID."
}

output "resolver_rule_ids" {
  value       = { for domain, rule in aws_route53_resolver_rule.forward : domain => rule.id }
  description = "Resolver forwarding rule IDs by domain."
}
