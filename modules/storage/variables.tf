variable "name" {
  description = "Weltweit eindeutiger Name des Storage Accounts"
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

variable "replication_type" {
  description = "Replikation (LRS, ZRS, GRS)"
  type        = string
}

variable "container_name" {
  description = "Name des Blob Containers"
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "Subnet für den Private Endpoint"
  type        = string
}

variable "private_dns_zone_id" {
  description = "Private DNS Zone privatelink.blob.core.windows.net"
  type        = string
}
