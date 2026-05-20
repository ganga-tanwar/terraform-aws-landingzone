variable "name" {
  type        = string
  description = "VPC endpoint name prefix."
}

variable "environment" {
  type        = string
  description = "Environment name."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID."
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for interface endpoints."
}

variable "route_table_ids" {
  type        = list(string)
  description = "Route table IDs for gateway endpoints."
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security group IDs for interface endpoints."
}

variable "interface_endpoints" {
  description = "Interface endpoint service suffixes."
  type        = set(string)
  default     = ["ssm", "ssmmessages", "ec2messages", "logs", "monitoring", "kms", "secretsmanager"]
}

variable "gateway_endpoints" {
  description = "Gateway endpoint service suffixes."
  type        = set(string)
  default     = ["s3", "dynamodb"]
}

variable "tags" {
  type        = map(string)
  description = "Common tags."
}
