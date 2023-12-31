terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.61.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.15.0 "
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.1"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}