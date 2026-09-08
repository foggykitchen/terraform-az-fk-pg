output "postgresql_server_id" {
  description = "PostgreSQL Flexible Server resource ID."
  value       = module.postgresql.id
}

output "postgresql_fqdn" {
  description = "PostgreSQL Flexible Server FQDN."
  value       = module.postgresql.fqdn
}

output "diagnostic_setting_ids" {
  description = "Diagnostic setting resource IDs."
  value       = module.postgresql.diagnostic_setting_ids
}

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace resource ID."
  value       = module.log_analytics.id
}

output "log_analytics_workspace_name" {
  description = "Log Analytics Workspace name."
  value       = module.log_analytics.name
}

output "database_ids" {
  description = "Created PostgreSQL database IDs."
  value       = module.postgresql.database_ids
}
