variable "primary_region" {
  type        = string
  description = "Primary AWS region."
  default     = "eu-north-1"
}

variable "account_email_domain" {
  type        = string
  description = "Email domain used for account vending examples."
}

variable "tags" {
  type        = map(string)
  description = "Common tags."
}
