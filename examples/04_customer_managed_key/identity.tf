module "postgresql_cmk_identity" {
  source = "github.com/foggykitchen/terraform-az-fk-managed-identity"

  name                = "${var.name_prefix}-cmk-uai"
  location            = azurerm_resource_group.foggykitchen_rg.location
  resource_group_name = azurerm_resource_group.foggykitchen_rg.name
  tags                = var.tags
}

module "postgresql_cmk_rbac" {
  source = "github.com/foggykitchen/terraform-az-fk-rbac"

  scope                = module.key_vault.key_vault_id
  principal_id         = module.postgresql_cmk_identity.principal_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
}
