variable "name" {
  description = "VPC name prefix."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
}

variable "azs" {
  description = "Availability zones."
  type        = list(string)
  validation {
    condition     = length(var.azs) == 3
    error_message = "Exactly three Availability Zones are required."
  }
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDRs."
}

variable "app_subnet_cidrs" {
  type        = list(string)
  description = "Private application subnet CIDRs."
}

variable "db_subnet_cidrs" {
  type        = list(string)
  description = "Private database subnet CIDRs."
}

variable "transit_gateway_id" {
  description = "Transit Gateway ID for spoke attachment. Leave null to skip attachment."
  type        = string
  default     = null
}

variable "flow_log_bucket_arn" {
  description = "Central S3 bucket ARN for VPC Flow Logs."
  type        = string
}

variable "enable_single_nat_gateway" {
  description = "Use one NAT Gateway. Intended only for non-production cost savings."
  type        = bool
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Common tags."
}
