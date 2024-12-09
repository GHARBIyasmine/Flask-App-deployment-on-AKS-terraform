terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }

    external = {
      source = "hashicorp/external"
      version = "2.3.4"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "external" {
  
}