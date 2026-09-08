data "azurerm_client_config" "current" {}

module "key_vault" {
  source = "github.com/foggykitchen/terraform-az-fk-key-vault"

  key_vault_name                = "${var.name_prefix}-kv-${random_string.key_vault_suffix.result}"
  location                      = azurerm_resource_group.foggykitchen_rg.location
  resource_group_name           = azurerm_resource_group.foggykitchen_rg.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  rbac_authorization_enabled    = true
  purge_protection_enabled      = true
  soft_delete_retention_days    = 90
  public_network_access_enabled = true
  tags                          = var.tags
}

module "key_vault_current_user_crypto_officer" {
  source = "github.com/foggykitchen/terraform-az-fk-rbac"

  scope                = module.key_vault.key_vault_id
  principal_id         = data.azurerm_client_config.current.object_id
  role_definition_name = "Key Vault Crypto Officer"
}

module "postgresql_cmk_key" {
  source = "github.com/foggykitchen/terraform-az-fk-key-vault-key"

  name         = var.key_vault_key_name
  key_vault_id = module.key_vault.key_vault_id
  tags         = var.tags

  depends_on = [
    module.key_vault_current_user_crypto_officer
  ]
}
