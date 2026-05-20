variable "organization_feature_set" {
  description = "AWS Organizations feature set."
  type        = string
  default     = "ALL"
}

variable "enabled_policy_types" {
  description = "Policy types enabled on the organization root."
  type        = list(string)
  default     = ["SERVICE_CONTROL_POLICY", "TAG_POLICY"]
}

variable "organizational_units" {
  description = "Organizational unit names to create under the root."
  type        = set(string)
  default     = ["Security", "Infrastructure", "Workloads"]
}

variable "accounts" {
  description = "Accounts to create or manage by OU."
  type = map(object({
    email     = string
    ou        = string
    role_name = optional(string, "OrganizationAccountAccessRole")
    tags      = optional(map(string), {})
  }))

  validation {
    condition     = alltrue([for account in values(var.accounts) : contains(var.organizational_units, account.ou)])
    error_message = "Each account ou must exist in organizational_units."
  }
}

variable "scp_policy_documents" {
  description = "Map of SCP name to JSON policy document."
  type        = map(string)
  default     = {}
}

variable "scp_attachments" {
  description = "Map of SCP name to OU names where it is attached."
  type        = map(list(string))
  default     = {}
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
}

variable "has_organization" {
  type        = bool
  default     = false
  description = "Set to true only if the AWS account already has an Organization created."
}
