output "postgresql_server_id" {
  description = "PostgreSQL Flexible Server resource ID."
  value       = module.postgresql.id
}

output "postgresql_fqdn" {
  description = "PostgreSQL Flexible Server FQDN."
  value       = module.postgresql.fqdn
}

output "database_ids" {
  description = "Created PostgreSQL database IDs."
  value       = module.postgresql.database_ids
}

output "vnet_id" {
  description = "VNet resource ID."
  value       = module.vnet.vnet_id
}

output "db_subnet_id" {
  description = "Delegated PostgreSQL subnet ID."
  value       = module.vnet.subnet_ids["fk-subnet-db"]
}
