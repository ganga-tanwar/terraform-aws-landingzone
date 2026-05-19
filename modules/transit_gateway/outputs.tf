output "transit_gateway_id" {
  value       = aws_ec2_transit_gateway.this.id
  description = "Transit Gateway ID."
}

output "transit_gateway_arn" {
  value       = aws_ec2_transit_gateway.this.arn
  description = "Transit Gateway ARN."
}
