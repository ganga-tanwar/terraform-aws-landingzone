variable "primary_region" {
  type        = string
  description = "Primary AWS region."
  default     = "eu-north-1"
}

variable "organization_id" {
  type        = string
  description = "AWS Organization ID."
}

variable "trusted_principal_arns" {
  type        = list(string)
  description = "IAM principals allowed to assume Terraform and break-glass roles."
}

variable "tags" {
  type        = map(string)
  description = "Common tags."
}
