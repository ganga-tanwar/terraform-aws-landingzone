output "log_bucket_arn" {
  value       = module.logging.log_bucket_arn
  description = "Central log bucket ARN."
}

output "terraform_role_arn" {
  value       = module.iam_baseline.terraform_role_arn
  description = "Terraform deployment role ARN."
}
