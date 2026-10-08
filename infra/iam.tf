# -------------------------------------------------------------------
# Workload Identity für den Demo-Pod:
# Der Kubernetes ServiceAccount demo/demo-app darf sich als diese
# Identität anmelden und so ohne Secret auf Key Vault + Storage zugreifen.
# -------------------------------------------------------------------

resource "azurerm_user_assigned_identity" "workload" {
  name                = "id-${var.prefix}-workload"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = var.location
}

resource "azurerm_federated_identity_credential" "workload" {
  name                      = "aks-${var.workload_namespace}-${var.workload_service_account}"
  user_assigned_identity_id = azurerm_user_assigned_identity.workload.id
  issuer                    = module.aks.oidc_issuer_url
  audience                  = ["api://AzureADTokenExchange"]
  subject                   = "system:serviceaccount:${var.workload_namespace}:${var.workload_service_account}"
}

# Read-only für Secrets, nur in diesem Key Vault
resource "azurerm_role_assignment" "workload_kv" {
  scope                = module.key_vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.workload.principal_id
}

resource "azurerm_role_assignment" "workload_storage" {
  scope                = module.storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.workload.principal_id
}
