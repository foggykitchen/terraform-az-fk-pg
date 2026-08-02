output "postgresql_server_id" {
  description = "PostgreSQL Flexible Server resource ID."
  value       = module.postgresql.id
}

output "postgresql_fqdn" {
  description = "PostgreSQL Flexible Server FQDN."
  value       = module.postgresql.fqdn
}

output "private_endpoint_id" {
  description = "Private Endpoint resource ID."
  value       = module.postgres_private_endpoint.private_endpoint_id
}

output "private_endpoint_ip_addresses" {
  description = "Private Endpoint IP addresses."
  value       = module.postgres_private_endpoint.private_ip_addresses
}

output "database_ids" {
  description = "Created PostgreSQL database IDs."
  value       = module.postgresql.database_ids
}
