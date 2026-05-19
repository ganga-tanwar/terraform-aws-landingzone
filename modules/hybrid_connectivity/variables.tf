variable "name_prefix" {
  type        = string
  description = "Name prefix."
}

variable "vpc_id" {
  type        = string
  description = "Shared services VPC ID."
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets for Route53 Resolver endpoints."
}

variable "transit_gateway_id" {
  type        = string
  description = "Transit Gateway ID."
}

variable "on_premises_cidrs" {
  type        = list(string)
  description = "On-premises CIDR ranges."
  default     = []
}

variable "customer_gateway_ip" {
  type        = string
  description = "Customer gateway public IP. Null skips VPN creation."
  default     = null
}

variable "customer_gateway_bgp_asn" {
  type        = number
  description = "Customer gateway BGP ASN."
  default     = 65000
}

variable "direct_connect_gateway_asn" {
  type        = number
  description = "Direct Connect Gateway ASN."
  default     = 64520
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
