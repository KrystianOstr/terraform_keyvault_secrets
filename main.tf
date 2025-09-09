resource "random_id" "prefix" {
  byte_length = 4

  keepers = {
    environment = var.environment
  }
}

data "azurerm_client_config" "current" {

}

resource "azurerm_resource_group" "main_rg" {
  name     = var.rg_name
  location = var.location

  tags = local.tags
}

resource "azurerm_key_vault" "main_kv" {
  name                       = local.kv_name
  location                   = azurerm_resource_group.main_rg.location
  resource_group_name        = azurerm_resource_group.main_rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7

  rbac_authorization_enabled = true

  tags = local.tags
}

resource "azurerm_key_vault_secret" "kv_secret" {
  name         = "db-password"
  value        = var.db_password
  key_vault_id = azurerm_key_vault.main_kv.id

  depends_on = [azurerm_role_assignment.kv_secrets_officer]
}

resource "azurerm_role_assignment" "kv_secrets_officer" {
  scope                = azurerm_key_vault.main_kv.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

