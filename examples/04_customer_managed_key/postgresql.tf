module "postgresql" {
  source = "../../"

  name                = "${var.name_prefix}-server"
  location            = azurerm_resource_group.foggykitchen_rg.location
  resource_group_name = azurerm_resource_group.foggykitchen_rg.name

  postgresql_version     = "16"
  administrator_login    = var.pg_admin_username
  administrator_password = var.pg_admin_password
  sku_name               = "GP_Standard_D2s_v3"
  storage_mb             = 32768

  delegated_subnet_id           = module.vnet.subnet_ids["fk-subnet-db"]
  private_dns_zone_id           = module.private_dns.private_dns_zone_ids["${var.name_prefix}.postgres.database.azure.com"]
  public_network_access_enabled = false

  identity = {
    type = "UserAssigned"
    identity_ids = [
      module.postgresql_cmk_identity.id
    ]
    principal_ids = {
      (module.postgresql_cmk_identity.id) = module.postgresql_cmk_identity.principal_id
    }
    client_ids = {
      (module.postgresql_cmk_identity.id) = module.postgresql_cmk_identity.client_id
    }
  }

  customer_managed_key = {
    key_vault_key_id                  = module.postgresql_cmk_key.versionless_id
    primary_user_assigned_identity_id = module.postgresql_cmk_identity.id
  }

  databases = {
    foggydb = {}
  }

  tags = var.tags

  depends_on = [
    module.private_dns,
    module.postgresql_cmk_key,
    module.postgresql_cmk_rbac
  ]
}
