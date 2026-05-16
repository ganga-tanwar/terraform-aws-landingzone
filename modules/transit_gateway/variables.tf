variable "name" {
  description = "Transit Gateway name."
  type        = string
}

variable "asn" {
  description = "Amazon side ASN."
  type        = number
  default     = 64512
}

variable "share_with_principal_arns" {
  description = "AWS Organizations or account principal ARNs for RAM sharing."
  type        = set(string)
  default     = []
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
}
