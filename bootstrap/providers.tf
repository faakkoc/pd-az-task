provider "azurerm" {
  features {}

  subscription_id = var.subscription_id

  # Storage-Zugriff per Entra-ID-Login statt Access Key
  storage_use_azuread = true

  # Rechte nur auf RG-Ebene, keine Rechte auf Subscription-Ebene
  resource_provider_registrations = "none"
}
