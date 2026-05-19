variable "trusted_principal_arns" {
  description = "Principal ARNs allowed to assume landing zone roles."
  type        = list(string)
}

variable "terraform_role_name" {
  description = "Terraform deployment role name."
  type        = string
  default     = "TerraformDeploymentRole"
}

variable "break_glass_role_name" {
  description = "Emergency break-glass role name."
  type        = string
  default     = "BreakGlassAdminRole"
}

variable "permissions_boundary_arn" {
  description = "Optional permissions boundary for created roles."
  type        = string
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Common tags."
}
