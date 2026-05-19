variable "name_prefix" {
  type        = string
  description = "Name prefix."
}

variable "log_bucket_name" {
  type        = string
  description = "Central log bucket name."
}

variable "log_kms_key_arn" {
  type        = string
  description = "KMS key for CloudTrail and Config."
}

variable "is_organization_trail" {
  type        = bool
  description = "Create an organization trail."
  default     = true
}

variable "enable_macie" {
  type        = bool
  description = "Enable Macie."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Common tags."
}
