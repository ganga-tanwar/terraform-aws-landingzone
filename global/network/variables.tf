variable "primary_region" {
  type        = string
  description = "Primary AWS region."
  default     = "eu-north-1"
}

variable "log_bucket_arn" {
  type        = string
  description = "Central VPC Flow Logs bucket ARN."
}

variable "ram_principal_arns" {
  type        = set(string)
  description = "Organization or account principal ARNs for TGW sharing."
  default     = []
}

variable "on_premises_cidrs" {
  type        = list(string)
  description = "On-premises CIDRs."
  default     = []
}

variable "customer_gateway_ip" {
  type        = string
  description = "Optional VPN customer gateway public IP."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Common tags."
}
