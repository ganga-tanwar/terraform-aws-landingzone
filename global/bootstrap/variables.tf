variable "primary_region" {
  type        = string
  description = "Primary AWS region."
  default     = "us-east-2"
}

variable "state_bucket_name" {
  type        = string
  description = "Globally unique S3 bucket name for Terraform state."
}

variable "lock_table_name" {
  type        = string
  description = "DynamoDB table for Terraform state locking."
  default     = "terraform-locks"
}

variable "tags" {
  type        = map(string)
  description = "Common tags."
}
