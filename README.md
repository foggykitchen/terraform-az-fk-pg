# terraform-az-fk-pg

This repository contains a reusable Terraform / OpenTofu module and progressive examples for deploying **Azure Database for PostgreSQL Flexible Server**.

It is part of the [FoggyKitchen.com training ecosystem](https://foggykitchen.com) and is designed as a clean, composable database layer that integrates with existing Azure networking foundations such as VNets, delegated subnets, Private DNS Zones, and Private Endpoints.

Support expectations are documented in [SUPPORT.md](SUPPORT.md).

---

## Used By

This module is intended to be used as a building block by higher-level FoggyKitchen examples and landing zone patterns where PostgreSQL is consumed privately by application workloads.

## Purpose

The goal of this module is to provide a clear, educational, and architecture-aware reference implementation for Azure PostgreSQL:

- Focused on Azure Database for PostgreSQL Flexible Server
- Explicit inputs and outputs with no hidden networking assumptions
- Designed to integrate cleanly with:
  - Azure VNets
  - Delegated database subnets
  - Private DNS Zones
  - Private Endpoints
  - Firewall rules for controlled public access scenarios

This is not a full landing zone or opinionated platform module.
It is a learning-first, building-block module.

---

## What the module does

Depending on configuration and example used, the module can create:

- PostgreSQL Flexible Server
- Optional databases
- Optional PostgreSQL server configurations
- Optional firewall rules when public access is enabled
- Optional Microsoft Entra ID authentication and administrators
- Optional customer-managed key encryption with user-assigned managed identity
- Optional Azure Monitor diagnostic settings
- Private access through delegated subnet and Private DNS
- Public or Private Endpoint integration patterns when composed with other FoggyKitchen modules

The module intentionally does not create:

- Resource groups
- Virtual Networks or subnets
- Private DNS Zones
- Private Endpoints
- Network Security Groups
- Bastion hosts or validation clients
- Application schemas or seed data

Each of those concerns belongs in its own dedicated module or example layer.

---

## Repository Structure

```text
terraform-az-fk-pg/
├── examples/
│   ├── 01_private_access_delegated_subnet/
│   ├── 02_private_endpoint/
│   ├── 03_entra_auth/
│   ├── 04_customer_managed_key/
│   ├── 05_diagnostics/
│   └── README.md
├── main.tf
├── inputs.tf
├── outputs.tf
├── versions.tf
├── LICENSE
├── SUPPORT.md
└── README.md
```

---

## Example Usage

```hcl
module "postgresql" {
  source = "git::https://github.com/foggykitchen/terraform-az-fk-pg.git?ref=v0.1.0"

  name                = "fk-pg-dev"
  location            = "westeurope"
  resource_group_name = "fk-rg-dev"

  administrator_login    = "pgadmin"
  administrator_password = var.pg_admin_password

  delegated_subnet_id           = module.vnet.subnet_ids["fk-subnet-db"]
  private_dns_zone_id           = module.private_dns.private_dns_zone_ids["fk-pg-dev.postgres.database.azure.com"]
  public_network_access_enabled = false

  databases = {
    foggydb = {}
  }

  tags = {
    project = "foggykitchen"
    env     = "dev"
  }
}
```

For Azure private access through delegated subnets, the target subnet must be delegated to `Microsoft.DBforPostgreSQL/flexibleServers` and the Private DNS Zone must be linked to the VNet before the server is created. For Private Endpoint patterns, use `privatelink.postgres.database.azure.com`.

---

## Microsoft Entra ID Authentication

Microsoft Entra ID authentication is disabled by default. Enable it by setting `entra_authentication.enabled = true` and configure one or more `entra_administrators`.

```hcl
entra_authentication = {
  enabled               = true
  password_auth_enabled = false
  tenant_id             = var.tenant_id
}

entra_administrators = {
  database_admins = {
    principal_name = "fk-postgresql-admins"
    object_id      = var.entra_admin_group_object_id
    principal_type = "Group"
  }
}
```

When `password_auth_enabled = false`, the module omits local administrator credentials from the PostgreSQL Flexible Server resource.

For an end-to-end lab, compose the administrator principal with `terraform-az-fk-entra-user` and `terraform-az-fk-entra-group`, then pass the group `object_id` and `display_name` into `entra_administrators`.

---

## Customer-Managed Key Encryption

Customer-managed key encryption is disabled by default. To enable it, pass a Key Vault key ID and a user-assigned identity that has access to the key.

```hcl
identity = {
  type         = "UserAssigned"
  identity_ids = [azurerm_user_assigned_identity.postgresql_cmk.id]
  principal_ids = {
    (azurerm_user_assigned_identity.postgresql_cmk.id) = azurerm_user_assigned_identity.postgresql_cmk.principal_id
  }
  client_ids = {
    (azurerm_user_assigned_identity.postgresql_cmk.id) = azurerm_user_assigned_identity.postgresql_cmk.client_id
  }
}

customer_managed_key = {
  key_vault_key_id                  = var.key_vault_key_id
  primary_user_assigned_identity_id = azurerm_user_assigned_identity.postgresql_cmk.id
}
```

The module references Key Vault keys by ID only and does not create or manage key material. In composed examples, use `terraform-az-fk-managed-identity` for the user-assigned identity, `terraform-az-fk-rbac` for Key Vault crypto access, `terraform-az-fk-key-vault` for the Key Vault layer, and `terraform-az-fk-key-vault-key` for the key.

---

## Diagnostic Settings

Diagnostic settings are disabled by default. Configure one or more entries in `diagnostic_settings` to send PostgreSQL logs and metrics to Log Analytics, Storage, or Event Hubs.

```hcl
diagnostic_settings = {
  log_analytics = {
    name                       = "fk-pg-diag"
    log_analytics_workspace_id = var.log_analytics_workspace_id
    log_category_groups        = ["allLogs"]
    metric_categories          = ["AllMetrics"]
  }
}
```

By default, examples use the Azure Monitor `allLogs` category group. If you need explicit categories instead, set `log_category_groups = []` and provide `log_categories`; when `log_categories = null` and `log_category_groups = []`, the module discovers and enables all currently available PostgreSQL Flexible Server log categories.

Azure Database for PostgreSQL Flexible Server exposes these diagnostic log categories:

| Category | Description |
|----------|-------------|
| `PostgreSQLLogs` | PostgreSQL server logs |
| `PostgreSQLFlexSessions` | PostgreSQL sessions data |
| `PostgreSQLFlexQueryStoreRuntime` | Query Store runtime statistics |
| `PostgreSQLFlexQueryStoreWaitStats` | Query Store wait statistics |
| `PostgreSQLQueryStoreSqlText` | Query Store SQL text |
| `PostgreSQLFlexTableStats` | Autovacuum and schema statistics |
| `PostgreSQLFlexDatabaseXacts` | Database transaction age and wraparound statistics |
| `PostgreSQLFlexPGBouncer` | PgBouncer logs |

The Azure Monitor category groups are `allLogs` and `audit`. Metrics use `AllMetrics`.

Use `terraform-az-fk-log-analytics` v1.x to create or reference the Log Analytics workspace in an upstream composition layer, then pass the workspace resource ID to `diagnostic_settings[*].log_analytics_workspace_id`.

---

## Inputs

| Input | Description | Default |
|-------|-------------|---------|
| `name` | PostgreSQL Flexible Server name | n/a |
| `location` | Azure region | n/a |
| `resource_group_name` | Resource group name | n/a |
| `postgresql_version` | PostgreSQL engine version | `"16"` |
| `administrator_login` | PostgreSQL administrator login | `"pgadmin"` |
| `administrator_password` | PostgreSQL administrator password | `null` |
| `entra_authentication` | Optional Microsoft Entra ID authentication settings | `{}` |
| `entra_administrators` | Map of Microsoft Entra ID administrators | `{}` |
| `sku_name` | PostgreSQL Flexible Server SKU name | `"GP_Standard_D2s_v3"` |
| `storage_mb` | Storage size in MB | `32768` |
| `auto_grow_enabled` | Enable storage auto-grow | `true` |
| `backup_retention_days` | Backup retention in days | `7` |
| `geo_redundant_backup_enabled` | Enable geo-redundant backup | `false` |
| `zone` | Availability zone for the primary server | `null` |
| `delegated_subnet_id` | Delegated subnet ID for private access mode | `null` |
| `private_dns_zone_id` | Private DNS Zone ID used with delegated subnet private access | `null` |
| `public_network_access_enabled` | Enable public network access | `true` |
| `create_mode` | PostgreSQL Flexible Server create mode | `"Default"` |
| `source_server_id` | Source server ID for restore or replica create modes | `null` |
| `point_in_time_restore_time_in_utc` | Point-in-time restore timestamp in UTC | `null` |
| `high_availability` | Optional high availability settings | `null` |
| `maintenance_window` | Optional maintenance window | Sunday 22:00 |
| `identity` | Optional managed identity configuration; `principal_ids` and `client_ids` maps may be supplied for identity outputs | `null` |
| `customer_managed_key` | Optional customer-managed key encryption settings | `null` |
| `databases` | Map of PostgreSQL databases to create | `{}` |
| `firewall_rules` | Map of firewall rules for public access mode | `{}` |
| `configurations` | Map of PostgreSQL server parameters | `{}` |
| `diagnostic_settings` | Map of Azure Monitor diagnostic settings | `{}` |
| `tags` | Common tags | `{}` |

---

## Outputs

| Output | Description |
|--------|-------------|
| `id` | PostgreSQL Flexible Server resource ID |
| `name` | PostgreSQL Flexible Server name |
| `fqdn` | PostgreSQL Flexible Server FQDN |
| `version` | PostgreSQL engine version |
| `administrator_login` | PostgreSQL administrator login |
| `delegated_subnet_id` | Delegated subnet ID used by the server |
| `private_dns_zone_id` | Private DNS Zone ID used by the server |
| `public_network_access_enabled` | Whether public network access is enabled |
| `entra_authentication_enabled` | Whether Microsoft Entra ID authentication is enabled |
| `entra_administrator_principal_names` | Configured Microsoft Entra ID administrator principal names |
| `cmk_enabled` | Whether customer-managed key encryption is enabled |
| `identity_principal_ids` | User-assigned identity principal IDs keyed by identity resource ID |
| `identity_client_ids` | User-assigned identity client IDs keyed by identity resource ID |
| `database_ids` | Map of database resource IDs keyed by database name |
| `diagnostic_setting_ids` | Map of diagnostic setting resource IDs keyed by diagnostic setting key |

---

## Design Philosophy

- PostgreSQL is a data service, not a networking module
- Private connectivity is explicit and composed from separate FoggyKitchen modules
- Delegated subnet private access and Private Endpoint patterns are both supported
- Outputs expose IDs and FQDNs needed by higher-level application modules
- Defaults are suitable for training and development, not production policy enforcement

---

## Related Modules & Training

- [terraform-az-fk-vnet](https://github.com/foggykitchen/terraform-az-fk-vnet)
- [terraform-az-fk-private-dns](https://github.com/foggykitchen/terraform-az-fk-private-dns)
- [terraform-az-fk-private-endpoint](https://github.com/foggykitchen/terraform-az-fk-private-endpoint)
- [terraform-az-fk-compute](https://github.com/foggykitchen/terraform-az-fk-compute)
- [terraform-az-fk-nsg](https://github.com/foggykitchen/terraform-az-fk-nsg)
- [FoggyKitchen multicloud PostgreSQL@Azure training example](https://github.com/mlinxfeld/foggykitchen_multicloud/tree/main/module-05-database/azure)

---

## License

Licensed under the Universal Permissive License (UPL), Version 1.0.
See [LICENSE](LICENSE) for details.

---

© 2026 [FoggyKitchen.com](https://foggykitchen.com) - Cloud. Code. Clarity.
