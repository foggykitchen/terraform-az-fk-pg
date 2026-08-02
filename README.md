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
| `database_ids` | Map of database resource IDs keyed by database name |

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
