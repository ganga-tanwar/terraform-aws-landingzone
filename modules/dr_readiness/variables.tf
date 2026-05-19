variable "name_prefix" {
  type        = string
  description = "Name prefix."
}

variable "primary_bucket_arn" {
  type        = string
  description = "Optional primary S3 bucket ARN prepared for CRR."
  default     = null
}

variable "route53_zone_id" {
  type        = string
  description = "Optional hosted zone ID for failover records."
  default     = null
}

variable "failover_record_name" {
  type        = string
  description = "Optional DNS name for future failover."
  default     = null
}

variable "primary_dns_name" {
  type        = string
  description = "Primary target DNS name."
  default     = null
}

variable "secondary_dns_name" {
  type        = string
  description = "Secondary target DNS name."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Common tags."
}
