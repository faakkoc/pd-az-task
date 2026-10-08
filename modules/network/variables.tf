variable "prefix" {
  description = "Namenspräfix"
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

variable "address_space" {
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
