terraform {
  # >= 1.11 für ephemeral resources und write-only Attribute (secrets.tf)
  required_version = ">= 1.11"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.50" # value_wo bei azurerm_key_vault_secret
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7" # ephemeral "random_password"
    }
  }

  backend "azurerm" {
    resource_group_name  = "RG-Fatih-Akkoc"
    storage_account_name = "stpdaztfstateh42w0e" # aus bootstrap/
    container_name       = "infra"
    key                  = "terraform.tfstate"
    use_azuread_auth     = true
  }
}
