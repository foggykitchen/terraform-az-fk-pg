module "postgresql" {
  source = "../../"

  name                = "${var.name_prefix}-server"
  location            = azurerm_resource_group.foggykitchen_rg.location
  resource_group_name = azurerm_resource_group.foggykitchen_rg.name

  postgresql_version            = "16"
  administrator_login           = var.pg_admin_username
  administrator_password        = var.pg_admin_password
  sku_name                      = "GP_Standard_D2s_v3"
  storage_mb                    = 32768
  public_network_access_enabled = true

  databases = {
    foggydb = {}
  }

  tags = var.tags
}

module "postgres_private_endpoint" {
  source = "github.com/foggykitchen/terraform-az-fk-private-endpoint"

  name                = "${var.name_prefix}-pe"
  location            = azurerm_resource_group.foggykitchen_rg.location
  resource_group_name = azurerm_resource_group.foggykitchen_rg.name

  subnet_id                      = module.vnet.subnet_ids["fk-subnet-private-endpoint"]
  private_connection_resource_id = module.postgresql.id
  subresource_names              = ["postgresqlServer"]
  private_dns_zone_group_name    = "default"
  private_dns_zone_ids = [
    module.private_dns.private_dns_zone_ids["privatelink.postgres.database.azure.com"]
  ]

  tags = var.tags

  depends_on = [
    module.private_dns
  ]
}
