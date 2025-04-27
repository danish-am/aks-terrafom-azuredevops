terraform {
  backend "azurerm" {
    resource_group_name  = "my-aks-rg"
    storage_account_name = "aksdanish"
    container_name       = "tfstate"
    key                  = "aks-cluster.terraform.tfstate"
  }
}
