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

output "database_ids" {
  description = "Map of database resource IDs keyed by database name."
  value = {
    for database_name, database in azurerm_postgresql_flexible_server_database.this :
    database_name => database.id
  }
}
