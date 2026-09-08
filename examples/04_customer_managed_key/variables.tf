variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "westeurope"
}

variable "name_prefix" {
  description = "Name prefix for example resources."
  type        = string
  default     = "fk-pg04"
}

variable "vnet_address_space" {
  description = "VNet address space."
  type        = string
  default     = "10.80.0.0/16"
}

variable "pg_admin_username" {
  description = "PostgreSQL administrator login."
  type        = string
  default     = "pgadmin"
}

variable "pg_admin_password" {
  description = "PostgreSQL administrator password."
  type        = string
  sensitive   = true
}

variable "key_vault_key_name" {
  description = "Key Vault key name used for PostgreSQL customer-managed encryption."
  type        = string
  default     = "postgresql-cmk"
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default = {
    project     = "foggykitchen"
    environment = "dev"
    managed_by  = "opentofu"
  }
}
