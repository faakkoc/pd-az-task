output "tfstate_storage_account_name" {
  description = "Name des Storage Accounts für Terraform State"
  value       = azurerm_storage_account.tfstate.name
}

output "azure_client_id" {
  description = "GitHub Variable AZURE_CLIENT_ID"
  value       = azurerm_user_assigned_identity.github.client_id
}

output "azure_tenant_id" {
  description = "GitHub Variable AZURE_TENANT_ID"
  value       = data.azurerm_client_config.current.tenant_id
}

output "azure_subscription_id" {
  description = "GitHub Variable AZURE_SUBSCRIPTION_ID"
  value       = var.subscription_id
}
