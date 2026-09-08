# Example 03 - Microsoft Entra Authentication

This example deploys Azure Database for PostgreSQL Flexible Server with private access through a delegated subnet and Microsoft Entra ID authentication enabled.

Password authentication is disabled in this example. The lab creates a Microsoft Entra user with `terraform-az-fk-entra-user`, creates a Microsoft Entra security group with `terraform-az-fk-entra-group`, adds the user to the group, and configures the group as the PostgreSQL administrator.

## Architecture

- Resource group
- Microsoft Entra user composed with `terraform-az-fk-entra-user`
- Microsoft Entra security group composed with `terraform-az-fk-entra-group`
- VNet with an application subnet and a delegated PostgreSQL subnet
- Private DNS Zone linked to the VNet
- PostgreSQL Flexible Server with Entra authentication enabled
- One Entra group administrator mapped to PostgreSQL
- One sample database

![Microsoft Entra authentication architecture](03_entra_auth_architecture.jpg)

## Login Flow

1. Terraform creates the Entra administrator user.
2. Terraform creates the Entra administrator group and adds the user as a member.
3. The user obtains an access token for Azure Database for PostgreSQL.
4. The PostgreSQL client connects to the private server FQDN from a network path that can resolve the private DNS zone.
5. The token is supplied as the password and the Entra principal name is supplied as the user name.

Example token retrieval:

```bash
az account get-access-token --resource-type oss-rdbms --query accessToken -o tsv
```

## Usage

```bash
cd examples/03_entra_auth
cp terraform.tfvars.example terraform.tfvars
tofu init
tofu plan
```

Update `terraform.tfvars` with a real Entra tenant domain in `entra_admin_user_principal_name` and a strong initial password before planning. The password is marked sensitive and is not hardcoded in the module.

The AzureAD identity running this example needs permission to create and manage Entra users and groups.

## Validation Screenshots

The following screenshots show the expected Azure Portal state after a successful apply.

![PostgreSQL Entra-only authentication](03_entra_auth_pg_authentication.jpg)

![PostgreSQL private networking](03_entra_auth_pg_networking.jpg)

![Microsoft Entra administrator group](03_entra_auth_entra_group_overview.jpg)

![Microsoft Entra administrator group member](03_entra_auth_entra_group_members.jpg)

![Private DNS VNet link](03_entra_auth_private_dns.jpg)
