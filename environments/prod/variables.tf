variable "primary_region" {
  type    = string
  default = "eu-north-1"
}

variable "transit_gateway_id" {
  type = string
}

variable "log_bucket_arn" {
  type = string
}

variable "windows_sql_ami_id" {
  type = string
}

variable "allowed_management_cidrs" {
  type    = list(string)
  default = []
}

variable "tags" {
  type = map(string)
}
