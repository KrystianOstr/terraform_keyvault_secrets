variable "sub_id" {
  type        = string
  description = "Sub ID"
}

variable "rg_name" {
  type        = string
  description = "Name of resource group"
  default     = "kv-secrets-rg"
}

variable "location" {
  type        = string
  description = "Location of resources"
  default     = "West Europe"
}

variable "environment" {
  type        = string
  description = "Current environment for app"
}

variable "owner" {
  type        = string
  description = "Owner's name"
}

variable "db_password" {
  type        = string
  description = "SENSITIVE - password for DB"
  sensitive   = true
}
