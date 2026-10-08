provider "azurerm" {
  features {}

  subscription_id = var.subscription_id

  # Storage-Zugriff per Entra-ID-Login statt Access Key
  storage_use_azuread = true

  # Wir haben nur Rechte auf der Resource Group, nicht auf der Subscription
  resource_provider_registrations = "none"
}
