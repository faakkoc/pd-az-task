terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  # Erster Apply lokal, im Anschluss State Migration
  backend "azurerm" {
    resource_group_name  = "RG-Fatih-Akkoc"
    storage_account_name = "stpdaztfstateh42w0e"
    container_name       = "bootstrap"
    key                  = "terraform.tfstate"
    use_azuread_auth     = true
  }
}
