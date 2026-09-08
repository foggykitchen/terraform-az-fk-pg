module "log_analytics" {
  source = "github.com/foggykitchen/terraform-az-fk-log-analytics"

  name                = "${var.name_prefix}-law"
  location            = azurerm_resource_group.foggykitchen_rg.location
  resource_group_name = azurerm_resource_group.foggykitchen_rg.name
  retention_in_days   = var.log_analytics_retention_in_days
  daily_quota_gb      = var.log_analytics_daily_quota_gb
  tags                = var.tags
}
