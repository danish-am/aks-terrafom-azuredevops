variable "resource_group_name" {
  description = "The name of the Resource Group where AKS will be created."
  type        = string
}

variable "location" {
  description = "Azure Region where resources will be deployed."
  type        = string
  default     = "eastus"
}

variable "aks_cluster_name" {
  description = "The name of the AKS cluster."
  type        = string
}

variable "dns_prefix" {
  description = "The DNS prefix for the AKS cluster."
  type        = string
}

variable "node_count" {
  description = "Number of nodes in the default node pool."
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "The size of the Virtual Machines in the node pool."
  type        = string
  default     = "Standard_DS2_v2"
}
