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

  databases = {
    foggydb = {}
  }

  tags = var.tags

  depends_on = [
    module.private_dns
  ]
}
