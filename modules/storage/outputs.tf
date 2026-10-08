output "id" {
  value = azurerm_storage_account.this.id
}

output "name" {
  value = azurerm_storage_account.this.name
}

output "private_ip" {
  value = azurerm_private_endpoint.blob.private_service_connection[0].private_ip_address
}
