# Zentraler Storage für die Terraform States.
# Pro Stage ein eigener Container, damit Rechte getrennt
# vergeben werden können: Die Pipeline darf nur den infra-State anfassen.

resource "azurerm_storage_account" "tfstate" {
  name                     = "st${var.prefix}tfstate${random_string.suffix.result}"
  resource_group_name      = data.azurerm_resource_group.this.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Zugriff nur per Entra-ID-Login + RBAC, keine Access Keys
  shared_access_key_enabled       = false
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  blob_properties {
    # Versionierung für Rollback von Terraform States
    versioning_enabled = true
  }
}

resource "azurerm_storage_container" "bootstrap" {
  name                  = "bootstrap"
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "infra" {
  name                  = "infra"
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}
