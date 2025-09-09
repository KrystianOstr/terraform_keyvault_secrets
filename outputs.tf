output "prefix" {
  value = random_id.prefix.hex
}

output "kv_name" {
  value = azurerm_key_vault.main_kv.name
}

output "vault_uri" {
  value = azurerm_key_vault.main_kv.vault_uri
}

output "secret_id" {
  value = azurerm_key_vault_secret.kv_secret.id
}