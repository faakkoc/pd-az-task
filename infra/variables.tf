variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Bestehende Resource Group"
  type        = string
}

variable "location" {
  description = "Azure Region"
  type        = string
}

variable "prefix" {
  description = "Namenspräfix, z.B. 'pdaz-dev'"
  type        = string
}

# Netzwerk
variable "vnet_address_space" {
  description = "Adressraum des VNets"
  type        = string
}

variable "aks_subnet_prefix" {
  description = "Adressbereich des AKS-Subnets"
  type        = string
}

variable "private_endpoint_subnet_prefix" {
  description = "Adressbereich des Private-Endpoint-Subnets"
  type        = string
}

# Key Vault
variable "key_vault_purge_protection" {
  description = "Purge Protection für den Key Vault"
  type        = bool
}

# Storage
variable "storage_replication_type" {
  description = "Replikation des Storage Accounts"
  type        = string
}

variable "storage_container_name" {
  description = "Name des Blob Containers"
  type        = string
}

# AKS
variable "aks_node_count" {
  description = "Anzahl AKS Nodes"
  type        = number
}

variable "aks_vm_size" {
  description = "VM-Größe der AKS Nodes"
  type        = string
}

variable "aks_service_cidr" {
  description = "IP-Bereich für Kubernetes Services (nicht im VNet)"
  type        = string
}

variable "aks_dns_service_ip" {
  description = "IP des Cluster-DNS"
  type        = string
}

variable "aks_admin_object_ids" {
  description = "Entra ID Object IDs mit Cluster-Admin-Rechten"
  type        = list(string)
}

# Secrets
variable "demo_secret_version" {
  description = "Version des Demo-Secrets. Erhöhen, um ein neues Passwort zu erzeugen (Rotation)"
  type        = number
}

# Workload Identity
variable "workload_namespace" {
  description = "Kubernetes Namespace des Demo-Pods"
  type        = string
}

variable "workload_service_account" {
  description = "Kubernetes ServiceAccount des Demo-Pods"
  type        = string
}
