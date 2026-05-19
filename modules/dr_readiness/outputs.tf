output "dr_backup_vault_arn" {
  value       = aws_backup_vault.dr.arn
  description = "DR backup vault ARN."
}

output "replica_bucket_arn" {
  value       = aws_s3_bucket.replica.arn
  description = "DR replica bucket ARN."
}

output "dr_kms_key_arn" {
  value       = aws_kms_key.dr.arn
  description = "DR KMS key ARN."
}
