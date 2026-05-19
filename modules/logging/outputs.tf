output "log_bucket_name" {
  value       = aws_s3_bucket.logs.id
  description = "Central log archive bucket name."
}

output "log_bucket_arn" {
  value       = aws_s3_bucket.logs.arn
  description = "Central log archive bucket ARN."
}

output "log_kms_key_arn" {
  value       = aws_kms_key.logs.arn
  description = "Log archive KMS key ARN."
}
