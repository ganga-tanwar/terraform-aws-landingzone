variable "name_prefix" {
  description = "Prefix for log archive resources."
  type        = string
}

variable "organization_id" {
  description = "AWS Organization ID allowed to write logs."
  type        = string
  default     = null
}

variable "enable_mfa_delete" {
  description = "Documented switch for MFA delete. Terraform AWS provider cannot enable MFA delete without root MFA."
  type        = bool
  default     = false
}

variable "lifecycle_transition_days" {
  description = "Days before logs move to Glacier Instant Retrieval."
  type        = number
  default     = 90
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
}
