output "aks_subnet_id" {
  value = azurerm_subnet.aks.id
}

output "private_endpoint_subnet_id" {
  value = azurerm_subnet.private_endpoints.id
}

output "key_vault_dns_zone_id" {
  value = azurerm_private_dns_zone.key_vault.id
}

output "blob_dns_zone_id" {
  value = azurerm_private_dns_zone.blob.id
}
