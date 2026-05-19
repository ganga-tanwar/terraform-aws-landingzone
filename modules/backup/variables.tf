variable "name_prefix" {
  type        = string
  description = "Name prefix."
}

variable "backup_vault_kms_key_arn" {
  type        = string
  description = "KMS key ARN for backup vault."
  default     = null
}

variable "backup_selection_tag_value" {
  type        = string
  description = "BackupPolicy tag value selected by AWS Backup."
  default     = "Daily"
}

variable "dr_vault_arn" {
  type        = string
  description = "Optional DR vault ARN for cross-region copy."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Common tags."
}
