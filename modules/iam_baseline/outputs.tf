output "terraform_role_arn" {
  value       = aws_iam_role.terraform.arn
  description = "Terraform deployment role ARN."
}

output "break_glass_role_arn" {
  value       = aws_iam_role.break_glass.arn
  description = "Break-glass role ARN."
}
