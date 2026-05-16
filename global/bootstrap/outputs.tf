output "state_bucket_name" {
  value       = aws_s3_bucket.state.id
  description = "Terraform state bucket."
}

output "lock_table_name" {
  value       = aws_dynamodb_table.locks.name
  description = "Terraform lock table."
}
