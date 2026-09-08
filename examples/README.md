# Azure PostgreSQL with Terraform/OpenTofu - Training Examples

This directory contains progressive examples used with the **terraform-az-fk-pg** module.
The examples are designed as incremental building blocks for private PostgreSQL architectures on Azure.

These examples are part of the [FoggyKitchen.com training ecosystem](https://foggykitchen.com/courses-2/) and are meant to be applied independently for learning and experimentation.

---

## Example Overview

| Example | Title | Key Topics |
|:-------:|:------|:-----------|
| 01 | **Private Access with Delegated Subnet** | PostgreSQL Flexible Server, VNet injection, delegated subnet, Private DNS |
| 02 | **Private Endpoint** | PostgreSQL Flexible Server, FoggyKitchen Private Endpoint module, Private DNS Zone Group |
| 03 | **Microsoft Entra Authentication** | PostgreSQL Flexible Server, delegated subnet, FoggyKitchen Entra User, FoggyKitchen Entra Group, group administrator |
| 04 | **Customer-Managed Key Encryption** | PostgreSQL Flexible Server, delegated subnet, FoggyKitchen Key Vault, FoggyKitchen Key Vault Key, FoggyKitchen Managed Identity, FoggyKitchen RBAC |
| 05 | **Diagnostic Settings** | PostgreSQL Flexible Server, delegated subnet, Azure Monitor, FoggyKitchen Log Analytics |

---

## How to Use

Each example directory contains:

- Terraform/OpenTofu configuration (`.tf`)
- A focused `README.md` explaining the goal of the example
- A `terraform.tfvars.example` file with placeholder values

To run an example:

```bash
cd examples/01_private_access_delegated_subnet
cp terraform.tfvars.example terraform.tfvars
tofu init
tofu plan
tofu apply
```

The recommended learning path is sequential:

```text
01 -> 02 -> 03 -> 04 -> 05
```

---

## Design Principles

- One example = one architectural goal
- PostgreSQL is isolated from networking concerns in the root module
- Networking, Private DNS, and Private Endpoints are composed with dedicated FoggyKitchen modules
- Examples avoid hidden dependencies between directories

---

## Related Resources

- [FoggyKitchen Azure PostgreSQL Module](../)
- [FoggyKitchen Azure VNet Module](https://github.com/foggykitchen/terraform-az-fk-vnet)
- [FoggyKitchen Azure Private DNS Module](https://github.com/foggykitchen/terraform-az-fk-private-dns)
- [FoggyKitchen Azure Private Endpoint Module](https://github.com/foggykitchen/terraform-az-fk-private-endpoint)
- [FoggyKitchen Azure Compute Module](https://github.com/foggykitchen/terraform-az-fk-compute)
- [FoggyKitchen Azure Key Vault Module](https://github.com/foggykitchen/terraform-az-fk-key-vault)
- [FoggyKitchen Azure Key Vault Key Module](https://github.com/foggykitchen/terraform-az-fk-key-vault-key)

---

## License

Licensed under the Universal Permissive License (UPL), Version 1.0.
See [LICENSE](../LICENSE) for details.

---

© 2026 [FoggyKitchen.com](https://foggykitchen.com) - Cloud. Code. Clarity.
