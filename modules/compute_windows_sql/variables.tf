variable "name_prefix" {
  type        = string
  description = "Name prefix."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID."
}

variable "subnet_ids" {
  type        = list(string)
  description = "Private application/database subnet IDs for EC2 placement."
}

variable "security_group_ids" {
  type        = list(string)
  description = "Additional security groups."
  default     = []
}

variable "ami_id" {
  type        = string
  description = "Windows or SQL Server AMI ID."
}

variable "key_name" {
  type        = string
  description = "Optional EC2 key pair name."
  default     = null
}

variable "instances" {
  description = "Migrated Windows and SQL instances."
  type = map(object({
    instance_type          = string
    subnet_index           = number
    workload_type          = string
    os_volume_size         = optional(number, 128)
    data_volume_size       = optional(number, 0)
    data_volume_iops       = optional(number, 3000)
    data_volume_throughput = optional(number, 125)
  }))
}

variable "allowed_management_cidrs" {
  type        = list(string)
  description = "CIDRs allowed for RDP during migration. Prefer SSM Session Manager after cutover."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Common tags."
}
