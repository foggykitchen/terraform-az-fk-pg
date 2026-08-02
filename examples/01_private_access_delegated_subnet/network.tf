module "vnet" {
  source = "github.com/foggykitchen/terraform-az-fk-vnet"

  name                = "${var.name_prefix}-vnet"
  location            = azurerm_resource_group.foggykitchen_rg.location
  resource_group_name = azurerm_resource_group.foggykitchen_rg.name

  address_space = [var.vnet_address_space]

  subnets = {
    fk-subnet-app = {
      address_prefixes = ["10.50.10.0/24"]
    }

    fk-subnet-db = {
      address_prefixes = ["10.50.20.0/24"]
      delegations = [
        {
          name = "postgresql-flexible-server-delegation"
          service_delegation = {
            name    = "Microsoft.DBforPostgreSQL/flexibleServers"
            actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
          }
        }
      ]
    }
  }

  tags = var.tags
}

module "private_dns" {
  source = "github.com/foggykitchen/terraform-az-fk-private-dns"

  resource_group_name = azurerm_resource_group.foggykitchen_rg.name

  private_dns_zone_names = [
    "${var.name_prefix}.postgres.database.azure.com"
  ]

  vnet_links = {
    "${var.name_prefix}-vnet-link" = {
      vnet_id              = module.vnet.vnet_id
      registration_enabled = false
    }
  }

  tags = var.tags
}
