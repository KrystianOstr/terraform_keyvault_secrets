terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.43.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }

  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstate78234926512"
    container_name       = "tfstate"
    key                  = "kv-secrets/dev/terraform.tfstate"
    use_azuread_auth     = true


  }
}

provider "azurerm" {
  features {}
  subscription_id = var.sub_id
}

provider "random" {}