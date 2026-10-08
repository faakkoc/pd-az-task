output "key_vault_name" {
  description = "Name des Key Vaults"
  value       = module.key_vault.name
}

output "key_vault_private_ip" {
  description = "Private IP des Key Vault Private Endpoints"
  value       = module.key_vault.private_ip
}

output "storage_account_name" {
  description = "Name des Storage Accounts"
  value       = module.storage.name
}

output "storage_private_ip" {
  description = "Private IP des Blob Private Endpoints"
  value       = module.storage.private_ip
}

output "aks_cluster_name" {
  description = "Name des AKS Clusters"
  value       = module.aks.name
}

output "workload_client_id" {
  description = "Client ID der Workload Identity (für den Kubernetes ServiceAccount)"
  value       = azurerm_user_assigned_identity.workload.client_id
}

output "kubectl_config_command" {
  description = "kubectl für den Cluster konfigurieren"
  value       = "az aks get-credentials -g ${var.resource_group_name} -n ${module.aks.name} && kubelogin convert-kubeconfig -l azurecli"
}
