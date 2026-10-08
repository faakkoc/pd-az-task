resource "azurerm_key_vault" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tenant_id           = var.tenant_id
  sku_name            = "standard"

  # Berechtigungen über Azure RBAC statt Access Policies.
  # Azure RBAC steuert den Zugriff zentral über IAM
  rbac_authorization_enabled = true

  soft_delete_retention_days = 7                            # Minimalwert, durch Azure gezwungen
  purge_protection_enabled   = var.purge_protection_enabled # False, um Cleanup in Dev/Test zu ermöglichen

  # Öffentlicher Endpunkt bleibt an, damit die GitHub-Pipeline
  # Secrets schreiben kann. Aus dem VNet läuft der Zugriff
  # über den Private Endpoint. Alternativ über selbst gehosteten
  # Runner im VNet.
  public_network_access_enabled = true
}

resource "azurerm_private_endpoint" "this" {
  name                = "pep-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-${var.name}"
    private_connection_resource_id = azurerm_key_vault.this.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  # Private IP wird automatisch in die Private DNS Zone eingetragen
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }
}
