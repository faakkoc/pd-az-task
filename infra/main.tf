# Einlesen bestehender RG
data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

# Aktuelle Azure-Konfiguration
data "azurerm_client_config" "current" {}

# Zufälliger Suffix für eindeutige Ressourcennamen
resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}

module "network" {
  source = "../modules/network"

  prefix                         = var.prefix
  resource_group_name            = data.azurerm_resource_group.this.name
  location                       = var.location
  address_space                  = var.vnet_address_space
  aks_subnet_prefix              = var.aks_subnet_prefix
  private_endpoint_subnet_prefix = var.private_endpoint_subnet_prefix
}

module "key_vault" {
  source = "../modules/key-vault"

  name                       = "kv-${var.prefix}-${random_string.suffix.result}"
  resource_group_name        = data.azurerm_resource_group.this.name
  location                   = var.location
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled   = var.key_vault_purge_protection
  private_endpoint_subnet_id = module.network.private_endpoint_subnet_id
  private_dns_zone_id        = module.network.key_vault_dns_zone_id
}

module "storage" {
  source = "../modules/storage"

  name                       = "st${replace(var.prefix, "-", "")}${random_string.suffix.result}"
  resource_group_name        = data.azurerm_resource_group.this.name
  location                   = var.location
  replication_type           = var.storage_replication_type
  container_name             = var.storage_container_name
  private_endpoint_subnet_id = module.network.private_endpoint_subnet_id
  private_dns_zone_id        = module.network.blob_dns_zone_id
}

module "aks" {
  source = "../modules/aks"

  name                = "aks-${var.prefix}"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = var.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  subnet_id           = module.network.aks_subnet_id
  node_count          = var.aks_node_count
  vm_size             = var.aks_vm_size
  service_cidr        = var.aks_service_cidr
  dns_service_ip      = var.aks_dns_service_ip
  admin_object_ids    = var.aks_admin_object_ids
}
