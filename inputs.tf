variable "name" {
  description = "PostgreSQL Flexible Server name."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "postgresql_version" {
  description = "PostgreSQL engine version."
  type        = string
  default     = "16"

  validation {
    condition     = contains(["11", "12", "13", "14", "15", "16"], var.postgresql_version)
    error_message = "postgresql_version must be one of: 11, 12, 13, 14, 15, 16."
  }
}

variable "administrator_login" {
  description = "PostgreSQL administrator login."
  type        = string
  default     = "pgadmin"
}

variable "administrator_password" {
  description = "PostgreSQL administrator password. Required when create_mode is Default."
  type        = string
  sensitive   = true
  default     = null
}

variable "entra_authentication" {
  description = "Optional Microsoft Entra ID authentication settings. When disabled, the authentication block is not rendered."
  type = object({
    enabled               = optional(bool, false)
    password_auth_enabled = optional(bool, true)
    tenant_id             = optional(string)
  })
  default = {}
}

variable "entra_administrators" {
  description = "Map of Microsoft Entra ID administrators for PostgreSQL Flexible Server."
  type = map(object({
    principal_name = string
    object_id      = string
    principal_type = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for administrator in var.entra_administrators :
      contains(["User", "Group", "ServicePrincipal"], administrator.principal_type)
    ])
    error_message = "entra_administrators principal_type must be one of: User, Group, ServicePrincipal."
  }
}

variable "sku_name" {
  description = "PostgreSQL Flexible Server SKU name."
  type        = string
  default     = "GP_Standard_D2s_v3"
}

variable "storage_mb" {
  description = "Storage size in MB."
  type        = number
  default     = 32768
}

variable "auto_grow_enabled" {
  description = "Enable storage auto-grow."
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Backup retention in days."
  type        = number
  default     = 7
}

variable "geo_redundant_backup_enabled" {
  description = "Enable geo-redundant backup."
  type        = bool
  default     = false
}

variable "zone" {
  description = "Availability zone for the primary server. Null lets Azure choose."
  type        = string
  default     = null
}

variable "delegated_subnet_id" {
  description = "Delegated subnet ID for private access mode. Leave null for public or Private Endpoint mode."
  type        = string
  default     = null
}

variable "private_dns_zone_id" {
  description = "Private DNS Zone ID used with delegated_subnet_id."
  type        = string
  default     = null
}

variable "public_network_access_enabled" {
  description = "Enable public network access. Must be false for delegated subnet private access. Private Endpoint examples may create a public-access server without firewall rules."
  type        = bool
  default     = true
}

variable "create_mode" {
  description = "PostgreSQL Flexible Server create mode."
  type        = string
  default     = "Default"
}

variable "source_server_id" {
  description = "Source server ID for restore or replica create modes."
  type        = string
  default     = null
}

variable "point_in_time_restore_time_in_utc" {
  description = "Point-in-time restore timestamp in UTC for restore scenarios."
  type        = string
  default     = null
}

variable "high_availability" {
  description = "Optional high availability settings."
  type = object({
    mode                      = string
    standby_availability_zone = optional(string)
  })
  default = null
}

variable "maintenance_window" {
  description = "Optional maintenance window."
  type = object({
    day_of_week  = number
    start_hour   = number
    start_minute = number
  })
  default = {
    day_of_week  = 0
    start_hour   = 22
    start_minute = 0
  }
}

variable "identity" {
  description = "Optional managed identity configuration for PostgreSQL Flexible Server."
  type = object({
    type          = string
    identity_ids  = list(string)
    principal_ids = optional(map(string), {})
    client_ids    = optional(map(string), {})
  })
  default = null

  validation {
    condition     = var.identity == null || var.identity.type == "UserAssigned"
    error_message = "identity.type must be UserAssigned when identity is set."
  }
}

variable "customer_managed_key" {
  description = "Optional customer-managed key encryption settings. Null keeps service-managed encryption."
  type = object({
    key_vault_key_id                     = string
    primary_user_assigned_identity_id    = string
    geo_backup_key_vault_key_id          = optional(string)
    geo_backup_user_assigned_identity_id = optional(string)
  })
  default = null
}

variable "databases" {
  description = "Map of PostgreSQL databases to create."
  type = map(object({
    charset   = optional(string, "UTF8")
    collation = optional(string, "en_US.utf8")
  }))
  default = {}
}

variable "firewall_rules" {
  description = "Map of firewall rules. Use only when public_network_access_enabled is true."
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  default = {}
}

variable "configurations" {
  description = "Map of PostgreSQL server parameters."
  type        = map(string)
  default     = {}
}

variable "diagnostic_settings" {
  description = "Map of Azure Monitor diagnostic settings for PostgreSQL Flexible Server."
  type = map(object({
    name                           = string
    log_analytics_workspace_id     = optional(string)
    storage_account_id             = optional(string)
    eventhub_authorization_rule_id = optional(string)
    eventhub_name                  = optional(string)
    log_categories                 = optional(list(string))
    log_category_groups            = optional(list(string), ["allLogs"])
    metric_categories              = optional(list(string), ["AllMetrics"])
  }))
  default = {}

  validation {
    condition = alltrue([
      for setting in values(var.diagnostic_settings) :
      setting.log_analytics_workspace_id != null ||
      setting.storage_account_id != null ||
      setting.eventhub_authorization_rule_id != null
    ])
    error_message = "Each diagnostic_settings entry must set at least one destination: log_analytics_workspace_id, storage_account_id, or eventhub_authorization_rule_id."
  }
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
