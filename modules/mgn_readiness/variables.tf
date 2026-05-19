variable "name_prefix" {
  type        = string
  description = "Name prefix."
}

variable "staging_area_subnet_id" {
  type        = string
  description = "Private subnet used by AWS Application Migration Service replication servers."
}

variable "replication_server_instance_type" {
  type        = string
  description = "MGN replication server instance type."
  default     = "t3.small"
}

variable "tags" {
  type        = map(string)
  description = "Common tags."
}
