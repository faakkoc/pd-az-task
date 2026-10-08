variable "name" {
  description = "Weltweit eindeutiger Name des Key Vaults"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group"
  type        = string
}

variable "location" {
  description = "Azure Region"
  type        = string
}

variable "tenant_id" {
  description = "Entra ID Tenant"
  type        = string
}

variable "purge_protection_enabled" {
  description = "Verhindert endgültiges Löschen des Key Vaults"
  type        = bool
}

variable "private_endpoint_subnet_id" {
  description = "Subnet für den Private Endpoint"
  type        = string
}

variable "private_dns_zone_id" {
  description = "Private DNS Zone privatelink.vaultcore.azure.net"
  type        = string
}
