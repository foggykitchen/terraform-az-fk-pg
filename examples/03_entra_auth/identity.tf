module "entra_admin_user" {
  source = "github.com/foggykitchen/terraform-az-fk-entra-user"

  user_principal_name = var.entra_admin_user_principal_name
  display_name        = var.entra_admin_user_display_name
  mail_nickname       = var.entra_admin_user_mail_nickname
  password            = var.entra_admin_user_password

  force_password_change = true

  tags = var.tags
}

module "entra_admin_group" {
  source = "github.com/foggykitchen/terraform-az-fk-entra-group"

  display_name = var.entra_admin_group_name
  description  = "PostgreSQL Flexible Server administrators for ${var.name_prefix}."
  members      = [module.entra_admin_user.object_id]

  tags = var.tags
}
