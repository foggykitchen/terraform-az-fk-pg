output "postgresql_server_id" {
  description = "PostgreSQL Flexible Server resource ID."
  value       = module.postgresql.id
}

output "postgresql_fqdn" {
  description = "PostgreSQL Flexible Server FQDN."
  value       = module.postgresql.fqdn
}

output "entra_authentication_enabled" {
  description = "Whether Microsoft Entra ID authentication is enabled."
  value       = module.postgresql.entra_authentication_enabled
}

output "entra_admin_group_object_id" {
  description = "Created Microsoft Entra administrator group object ID."
  value       = module.entra_admin_group.object_id
}

output "entra_admin_user_principal_name" {
  description = "Created Microsoft Entra administrator user principal name."
  value       = module.entra_admin_user.user_principal_name
}

output "entra_admin_user_object_id" {
  description = "Created Microsoft Entra administrator user object ID."
  value       = module.entra_admin_user.object_id
}

output "entra_administrator_principal_names" {
  description = "Configured Microsoft Entra ID administrator principal names."
  value       = module.postgresql.entra_administrator_principal_names
}

output "database_ids" {
  description = "Created PostgreSQL database IDs."
  value       = module.postgresql.database_ids
}
