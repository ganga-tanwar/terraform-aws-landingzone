output "backup_vault_arn" {
  value       = aws_backup_vault.this.arn
  description = "Backup vault ARN."
}

output "backup_plan_id" {
  value       = aws_backup_plan.this.id
  description = "Backup plan ID."
}
