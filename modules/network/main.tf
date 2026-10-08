resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.prefix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = [var.address_space]
}

resource "azurerm_subnet" "aks" {
  name                 = "snet-aks"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.aks_subnet_prefix]
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = "snet-private-endpoints"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.private_endpoint_subnet_prefix]

  # Ohne diese Einstellung ignoriert Azure die NSG für Private Endpoints
  private_endpoint_network_policies = "NetworkSecurityGroupEnabled"
}

# NSG: Nur HTTPS aus dem AKS-Subnet darf die Private Endpoints erreichen
# HTTPS ist nötig, weil Key Vault und Storage Account nur HTTPS unterstützen
resource "azurerm_network_security_group" "private_endpoints" {
  name                = "nsg-snet-private-endpoints"
  resource_group_name = var.resource_group_name
  location            = var.location

  security_rule {
    name                       = "Allow-HTTPS-From-AKS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = var.aks_subnet_prefix
    destination_address_prefix = "*"
  }

  # Sonstiges aus dem VNet wird blockiert
  security_rule {
    name                       = "Deny-VNet-Inbound"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "private_endpoints" {
  subnet_id                 = azurerm_subnet.private_endpoints.id
  network_security_group_id = azurerm_network_security_group.private_endpoints.id
}

# -------------------------------------------------------------------
# Private DNS Zones: Private Link leitet die Anfragen über die
# Private Endpoints, DNS-Auflösung läuft über die, mit dem VNet
# verlinkten Private DNS Zones.
# -------------------------------------------------------------------

resource "azurerm_private_dns_zone" "key_vault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "key_vault" {
  name                  = "link-key-vault"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault.name
  virtual_network_id    = azurerm_virtual_network.this.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                  = "link-blob"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.this.id
}
