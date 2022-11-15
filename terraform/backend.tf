terraform {
  backend "azurerm" {
    resource_group_name  = "blob-storage-rg"
    storage_account_name = "assessmentterraformstate"
    container_name       = "statefile"
    access_key           = "8yoGMI9rGwPoGL4/U0IC36sXG8m0lPOzBpF82MqHXLTTMvkOHPw4eAQTVSMKpZGTHz3SRfObJaYQ+AStcYgMrA=="
    key                  = "terraform.tfstate"
  }
}