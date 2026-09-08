output "postgresql_server_id" {
  description = "PostgreSQL Flexible Server resource ID."
  value       = module.postgresql.id
}

output "postgresql_fqdn" {
  description = "PostgreSQL Flexible Server FQDN."
  value       = module.postgresql.fqdn
}

output "cmk_enabled" {
  description = "Whether customer-managed key encryption is enabled."
  value       = module.postgresql.cmk_enabled
}

output "identity_principal_ids" {
  description = "User-assigned identity principal IDs keyed by identity resource ID."
  value       = module.postgresql.identity_principal_ids
}

output "identity_client_ids" {
  description = "User-assigned identity client IDs keyed by identity resource ID."
  value       = module.postgresql.identity_client_ids
}

output "cmk_identity_id" {
  description = "User-assigned managed identity resource ID."
  value       = module.postgresql_cmk_identity.id
}

output "cmk_identity_principal_id" {
  description = "User-assigned managed identity principal ID."
  value       = module.postgresql_cmk_identity.principal_id
}

output "cmk_identity_client_id" {
  description = "User-assigned managed identity client ID."
  value       = module.postgresql_cmk_identity.client_id
}

output "key_vault_id" {
  description = "Key Vault resource ID."
  value       = module.key_vault.key_vault_id
}

output "key_vault_name" {
  description = "Key Vault name."
  value       = module.key_vault.key_vault_name
}

output "key_vault_key_id" {
  description = "Versionless Key Vault key ID used for PostgreSQL customer-managed encryption."
  value       = module.postgresql_cmk_key.versionless_id
}

output "key_vault_key_resource_id" {
  description = "Versionless Azure resource ID of the Key Vault key used for PostgreSQL customer-managed encryption."
  value       = module.postgresql_cmk_key.resource_versionless_id
}

output "key_vault_current_user_role_assignment_id" {
  description = "Key Vault RBAC role assignment ID for the principal running OpenTofu."
  value       = module.key_vault_current_user_crypto_officer.role_assignment_id
}

output "key_vault_role_assignment_id" {
  description = "Key Vault RBAC role assignment ID for the PostgreSQL CMK identity."
  value       = module.postgresql_cmk_rbac.role_assignment_id
}

output "database_ids" {
  description = "Created PostgreSQL database IDs."
  value       = module.postgresql.database_ids
}
