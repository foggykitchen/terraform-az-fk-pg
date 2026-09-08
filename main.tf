data "azurerm_client_config" "current" {
  count = var.entra_authentication.enabled && var.entra_authentication.tenant_id == null ? 1 : 0
}

locals {
  password_auth_enabled = var.entra_authentication.enabled ? var.entra_authentication.password_auth_enabled : true
  entra_tenant_id       = var.entra_authentication.enabled ? coalesce(var.entra_authentication.tenant_id, try(data.azurerm_client_config.current[0].tenant_id, null)) : null
}

data "azurerm_monitor_diagnostic_categories" "this" {
  for_each = {
    for setting_key, setting in var.diagnostic_settings :
    setting_key => setting
    if setting.log_categories == null
  }

  resource_id = azurerm_postgresql_flexible_server.this.id
}

resource "azurerm_postgresql_flexible_server" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  version                           = var.postgresql_version
  administrator_login               = local.password_auth_enabled ? var.administrator_login : null
  administrator_password            = local.password_auth_enabled ? var.administrator_password : null
  sku_name                          = var.sku_name
  storage_mb                        = var.storage_mb
  auto_grow_enabled                 = var.auto_grow_enabled
  backup_retention_days             = var.backup_retention_days
  geo_redundant_backup_enabled      = var.geo_redundant_backup_enabled
  zone                              = var.zone
  delegated_subnet_id               = var.delegated_subnet_id
  private_dns_zone_id               = var.private_dns_zone_id
  public_network_access_enabled     = var.public_network_access_enabled
  create_mode                       = var.create_mode
  source_server_id                  = var.source_server_id
  point_in_time_restore_time_in_utc = var.point_in_time_restore_time_in_utc
  tags                              = var.tags

  dynamic "authentication" {
    for_each = var.entra_authentication.enabled ? [var.entra_authentication] : []

    content {
      active_directory_auth_enabled = true
      password_auth_enabled         = authentication.value.password_auth_enabled
      tenant_id                     = local.entra_tenant_id
    }
  }

  dynamic "identity" {
    for_each = var.identity == null ? [] : [var.identity]

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "customer_managed_key" {
    for_each = var.customer_managed_key == null ? [] : [var.customer_managed_key]

    content {
      key_vault_key_id                     = customer_managed_key.value.key_vault_key_id
      primary_user_assigned_identity_id    = customer_managed_key.value.primary_user_assigned_identity_id
      geo_backup_key_vault_key_id          = customer_managed_key.value.geo_backup_key_vault_key_id
      geo_backup_user_assigned_identity_id = customer_managed_key.value.geo_backup_user_assigned_identity_id
    }
  }

  dynamic "high_availability" {
    for_each = var.high_availability == null ? [] : [var.high_availability]

    content {
      mode                      = high_availability.value.mode
      standby_availability_zone = try(high_availability.value.standby_availability_zone, null)
    }
  }

  dynamic "maintenance_window" {
    for_each = var.maintenance_window == null ? [] : [var.maintenance_window]

    content {
      day_of_week  = maintenance_window.value.day_of_week
      start_hour   = maintenance_window.value.start_hour
      start_minute = maintenance_window.value.start_minute
    }
  }

  lifecycle {
    ignore_changes = [
      zone
    ]

    precondition {
      condition     = var.delegated_subnet_id == null || var.private_dns_zone_id != null
      error_message = "private_dns_zone_id is required when delegated_subnet_id is set."
    }

    precondition {
      condition     = !(var.delegated_subnet_id != null && var.private_dns_zone_id != null && var.public_network_access_enabled)
      error_message = "public_network_access_enabled must be false when delegated_subnet_id and private_dns_zone_id are set."
    }

    precondition {
      condition     = !var.entra_authentication.enabled || local.entra_tenant_id != null
      error_message = "entra_authentication.tenant_id is required when Entra authentication is enabled and the current AzureRM client tenant cannot be detected."
    }

    precondition {
      condition     = length(var.entra_administrators) == 0 || var.entra_authentication.enabled
      error_message = "entra_authentication.enabled must be true when entra_administrators are configured."
    }

    precondition {
      condition     = var.customer_managed_key == null || (var.identity != null && var.identity.type == "UserAssigned" && contains(var.identity.identity_ids, var.customer_managed_key.primary_user_assigned_identity_id))
      error_message = "customer_managed_key requires identity.type UserAssigned and identity.identity_ids must include customer_managed_key.primary_user_assigned_identity_id."
    }

    precondition {
      condition     = var.customer_managed_key == null || var.customer_managed_key.geo_backup_user_assigned_identity_id == null || (var.identity != null && contains(var.identity.identity_ids, var.customer_managed_key.geo_backup_user_assigned_identity_id))
      error_message = "identity.identity_ids must include customer_managed_key.geo_backup_user_assigned_identity_id when geo backup CMK identity is set."
    }
  }
}

resource "azurerm_postgresql_flexible_server_active_directory_administrator" "this" {
  for_each = var.entra_authentication.enabled ? var.entra_administrators : {}

  server_name         = azurerm_postgresql_flexible_server.this.name
  resource_group_name = azurerm_postgresql_flexible_server.this.resource_group_name
  tenant_id           = local.entra_tenant_id
  object_id           = each.value.object_id
  principal_name      = each.value.principal_name
  principal_type      = each.value.principal_type
}

resource "azurerm_postgresql_flexible_server_database" "this" {
  for_each = var.databases

  name      = each.key
  server_id = azurerm_postgresql_flexible_server.this.id
  charset   = each.value.charset
  collation = each.value.collation
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "this" {
  for_each = var.public_network_access_enabled ? var.firewall_rules : {}

  name             = each.key
  server_id        = azurerm_postgresql_flexible_server.this.id
  start_ip_address = each.value.start_ip_address
  end_ip_address   = each.value.end_ip_address
}

resource "azurerm_postgresql_flexible_server_configuration" "this" {
  for_each = var.configurations

  name      = each.key
  server_id = azurerm_postgresql_flexible_server.this.id
  value     = each.value
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each = var.diagnostic_settings

  name                           = each.value.name
  target_resource_id             = azurerm_postgresql_flexible_server.this.id
  log_analytics_workspace_id     = each.value.log_analytics_workspace_id
  storage_account_id             = each.value.storage_account_id
  eventhub_authorization_rule_id = each.value.eventhub_authorization_rule_id
  eventhub_name                  = each.value.eventhub_name

  dynamic "enabled_log" {
    for_each = concat(
      [
        for category in each.value.log_categories == null && length(each.value.log_category_groups) == 0 ? data.azurerm_monitor_diagnostic_categories.this[each.key].log_category_types : coalesce(each.value.log_categories, []) : {
          category       = category
          category_group = null
        }
      ],
      [
        for category_group in each.value.log_category_groups : {
          category       = null
          category_group = category_group
        }
      ]
    )

    content {
      category       = enabled_log.value.category
      category_group = enabled_log.value.category_group
    }
  }

  dynamic "enabled_metric" {
    for_each = toset(each.value.metric_categories)

    content {
      category = enabled_metric.value
    }
  }
}
