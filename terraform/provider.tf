terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}
provider "azurerm" {
  features {}
  subscription_id = "f81d7897-354d-4b09-80b2-f10120d4fd70"
  client_id       = "dccdc0c4-7c65-4aa1-b1c5-5bed892fb2a9"
  client_secret   = "Zv98Q~AECW6yoPATy6pKQ-9CnZSatYsgB2Vk7atf"
  tenant_id       = "f77b33e5-cfbc-4e3e-8bdc-59a3f2474cb5"
}