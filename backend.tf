terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-backend-aksrg"
    storage_account_name = "tfstatebackenddanish"
    container_name       = "tfstate"
    key                  = "aks-cluster.terraform.tfstate"
  }
}
