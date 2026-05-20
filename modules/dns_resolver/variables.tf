variable "name_prefix" {
  type        = string
  description = "Name prefix."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for Route 53 Resolver endpoints."
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets for Route 53 Resolver endpoints."
}

variable "on_premises_cidrs" {
  type        = list(string)
  description = "On-premises CIDR ranges allowed to query resolver endpoints."
  default     = []
}

variable "dns_forward_domains" {
  type        = map(list(string))
  description = "Domain to target DNS IPs for outbound resolver rules."
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Common tags."
}
