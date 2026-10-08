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
  description = "Namenspräfix für alle Ressourcen"
  type        = string
}

variable "github_repository" {
  description = "GitHub Repository im Format 'owner/repo'"
  type        = string
}
