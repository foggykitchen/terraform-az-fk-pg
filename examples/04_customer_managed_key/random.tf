resource "random_string" "key_vault_suffix" {
  length  = 6
  upper   = false
  special = false
}
