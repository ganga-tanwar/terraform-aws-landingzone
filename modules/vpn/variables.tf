variable "name_prefix" {
  type        = string
  description = "Name prefix."
}

variable "transit_gateway_id" {
  type        = string
  description = "Transit Gateway ID."
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

variable "create_direct_connect_gateway" {
  type        = bool
  description = "Create a Direct Connect Gateway alongside VPN connectivity."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Common tags."
}
