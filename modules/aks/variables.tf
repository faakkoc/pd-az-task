variable "name" {
  description = "Name des Clusters"
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

variable "subnet_id" {
  description = "Subnet für die Nodes"
  type        = string
}

variable "node_count" {
  description = "Anzahl Nodes"
  type        = number
}

variable "vm_size" {
  description = "VM-Größe der Nodes"
  type        = string
}

variable "service_cidr" {
  description = "IP-Bereich für Kubernetes Services"
  type        = string
}

variable "dns_service_ip" {
  description = "IP des Cluster-DNS (innerhalb service_cidr)"
  type        = string
}

variable "admin_object_ids" {
  description = "Entra ID Object IDs mit Cluster-Admin-Rechten"
  type        = list(string)
}
