# Example 04: Customer-Managed Key Encryption

In this fourth PostgreSQL example, we deploy an **Azure Database for PostgreSQL Flexible Server**
using **Terraform/OpenTofu** with **customer-managed key encryption at rest**.
The server is injected into a delegated database subnet, uses a linked Azure Private DNS Zone,
and receives a Key Vault key and user-assigned managed identity from composed FoggyKitchen modules.

This example creates the Key Vault with `terraform-az-fk-key-vault`, creates the Key Vault key
with `terraform-az-fk-key-vault-key`, creates the user-assigned identity with
`terraform-az-fk-managed-identity`, and grants Key Vault crypto access with `terraform-az-fk-rbac`.

---

## Architecture Overview

<img src="04_cmk_key_vault_architecture.jpg" width="900"/>

This deployment creates:

- A dedicated **Azure Resource Group**
- One **Key Vault** using `terraform-az-fk-key-vault`
- One **RSA Key Vault key** using `terraform-az-fk-key-vault-key`
- One **user-assigned managed identity** using `terraform-az-fk-managed-identity`
- Key Vault RBAC assignments using `terraform-az-fk-rbac`
- One **Azure VNet** using `terraform-az-fk-vnet`
- One application subnet for future client workloads
- One database subnet delegated to `Microsoft.DBforPostgreSQL/flexibleServers`
- One **Private DNS Zone** using `terraform-az-fk-private-dns`
- One **PostgreSQL Flexible Server** using the local `terraform-az-fk-pg` module
- One sample database named `foggydb`

This example demonstrates the secure-by-default PostgreSQL encryption pattern where the database
service uses a managed identity to access a Key Vault key by ID.

---

## Deployment Steps

Copy the example variables file and set a strong PostgreSQL administrator password:

```bash
cp terraform.tfvars.example terraform.tfvars
```

If you reuse a shared Azure training tfvars file, make sure it also provides
`pg_admin_password`. No key material or secrets are hardcoded in this example.

Initialize and apply the Terraform/OpenTofu configuration:

```bash
tofu init
tofu plan
tofu apply
```

After a successful deployment, OpenTofu will output:

- The PostgreSQL Flexible Server ID
- The PostgreSQL FQDN
- Whether CMK encryption is enabled
- The Key Vault ID
- The Key Vault key ID and resource ID
- The user-assigned managed identity ID, principal ID, and client ID
- The created database IDs

These outputs make it easy to verify that PostgreSQL encryption is connected to the expected
Key Vault key and managed identity.

---

## Runtime Notes

The Key Vault uses Azure RBAC and purge protection, which are required for a realistic PostgreSQL
CMK setup. The principal running OpenTofu receives `Key Vault Crypto Officer` so it can create the
key, and the PostgreSQL user-assigned identity receives `Key Vault Crypto Service Encryption User`
so the service can wrap and unwrap the data encryption key.

The PostgreSQL module references the Key Vault key by ID only. The key itself is created in the
example composition layer through `terraform-az-fk-key-vault-key`.

---

## Azure Console And Runtime Verification

### PostgreSQL Data Encryption

Confirm that PostgreSQL Flexible Server data encryption uses the customer-managed key.

<img src="04_cmk_pg_data_encryption.jpg" width="900"/>

### Key Vault

Confirm that the Key Vault exists with soft-delete and purge protection enabled.

<img src="04_cmk_key_vault_overview.jpg" width="900"/>

### Key Vault Key

Confirm that the RSA key used by PostgreSQL encryption exists in the Key Vault.

<img src="04_cmk_key_vault_key.jpg" width="900"/>

### Key Vault RBAC

Confirm that the current principal and PostgreSQL managed identity have the required Key Vault
crypto roles.

<img src="04_cmk_key_vault_rbac.jpg" width="900"/>

### Managed Identity

Confirm that the user-assigned managed identity used by PostgreSQL CMK exists.

<img src="04_cmk_managed_identity_overview.jpg" width="900"/>

---

## Cleanup

To remove all resources created by this example:

```bash
tofu destroy
```

---

## Summary

This example demonstrates:

- How to enable **customer-managed key encryption** for PostgreSQL Flexible Server
- How to create a Key Vault with `terraform-az-fk-key-vault`
- How to create a Key Vault key with `terraform-az-fk-key-vault-key`
- How to create a user-assigned managed identity with `terraform-az-fk-managed-identity`
- How to grant Key Vault crypto access with `terraform-az-fk-rbac`
- How to keep key material and identity concerns outside the root PostgreSQL module

---

## Learn More

Visit [FoggyKitchen.com](https://foggykitchen.com/) for Azure, OCI, multicloud, and Terraform/OpenTofu learning resources.

---

## License

Licensed under the **Universal Permissive License (UPL), Version 1.0**.
See [LICENSE](../../LICENSE) for more details.

---

© 2026 [FoggyKitchen.com](https://foggykitchen.com) - Cloud. Code. Clarity.
