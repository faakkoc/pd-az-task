# -------------------------------------------------------------------
# GitHub-Identität (Scope: Resource Group)
# -------------------------------------------------------------------

# Ressourcen anlegen/ändern
resource "azurerm_role_assignment" "github_contributor" {
  scope                = data.azurerm_resource_group.this.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.github.principal_id
}

# Rollen für RBAC-Management (z.B. weitere Rollen zuweisen)
resource "azurerm_role_assignment" "github_rbac_admin" {
  scope                = data.azurerm_resource_group.this.id
  role_definition_name = "Role Based Access Control Administrator"
  principal_id         = azurerm_user_assigned_identity.github.principal_id
}

# Rollen auf Data Plane Ressourcen zum Lesen/Schreiben von Secrets und State
resource "azurerm_role_assignment" "github_kv_secrets" {
  scope                = data.azurerm_resource_group.this.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = azurerm_user_assigned_identity.github.principal_id
}

# Nur der infra-Container, an den Bootstrap-State kommt die Pipeline nicht
resource "azurerm_role_assignment" "github_tfstate" {
  scope                = azurerm_storage_container.infra.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.github.principal_id
}

# -------------------------------------------------------------------
# Lokale Identität (Scope: Resource Group)
# -------------------------------------------------------------------

resource "azurerm_role_assignment" "admin_kv_secrets" {
  scope                = data.azurerm_resource_group.this.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "admin_tfstate" {
  scope                = azurerm_storage_account.tfstate.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}
