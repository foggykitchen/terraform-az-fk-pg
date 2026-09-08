output "id" {
  description = "PostgreSQL Flexible Server resource ID."
  value       = azurerm_postgresql_flexible_server.this.id
}

output "name" {
  description = "PostgreSQL Flexible Server name."
  value       = azurerm_postgresql_flexible_server.this.name
}

output "fqdn" {
  description = "PostgreSQL Flexible Server FQDN."
  value       = azurerm_postgresql_flexible_server.this.fqdn
}

output "version" {
  description = "PostgreSQL engine version."
  value       = azurerm_postgresql_flexible_server.this.version
}

output "administrator_login" {
  description = "PostgreSQL administrator login."
  value       = azurerm_postgresql_flexible_server.this.administrator_login
}

output "delegated_subnet_id" {
  description = "Delegated subnet ID used by the server."
  value       = azurerm_postgresql_flexible_server.this.delegated_subnet_id
}

output "private_dns_zone_id" {
  description = "Private DNS Zone ID used by the server."
  value       = azurerm_postgresql_flexible_server.this.private_dns_zone_id
}

output "public_network_access_enabled" {
  description = "Whether public network access is enabled."
  value       = azurerm_postgresql_flexible_server.this.public_network_access_enabled
}

output "entra_authentication_enabled" {
  description = "Whether Microsoft Entra ID authentication is enabled."
  value       = var.entra_authentication.enabled
}

output "entra_administrator_principal_names" {
  description = "Configured Microsoft Entra ID administrator principal names."
  value = {
    for administrator_key, administrator in azurerm_postgresql_flexible_server_active_directory_administrator.this :
    administrator_key => administrator.principal_name
  }
}

output "cmk_enabled" {
  description = "Whether customer-managed key encryption is enabled."
  value       = var.customer_managed_key != null
}

output "identity_principal_ids" {
  description = "User-assigned identity principal IDs keyed by identity resource ID."
  value       = var.identity == null ? {} : var.identity.principal_ids
}

output "identity_client_ids" {
  description = "User-assigned identity client IDs keyed by identity resource ID."
  value       = var.identity == null ? {} : var.identity.client_ids
}

output "database_ids" {
  description = "Map of database resource IDs keyed by database name."
  value = {
    for database_name, database in azurerm_postgresql_flexible_server_database.this :
    database_name => database.id
  }
}

output "diagnostic_setting_ids" {
  description = "Map of diagnostic setting resource IDs keyed by diagnostic setting key."
  value = {
    for setting_key, setting in azurerm_monitor_diagnostic_setting.this :
    setting_key => setting.id
  }
}
