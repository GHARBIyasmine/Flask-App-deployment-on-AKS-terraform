# Fetch the resource group if it already exists
data "azurerm_resource_group" "existing_rg" {
  name = var.resource_group_name
}

# Resource Group - only create if it doesn't already exist
resource "azurerm_resource_group" "rg" {
  count    = data.azurerm_resource_group.existing_rg == null ? 1 : 0
  name     = var.resource_group_name
  location = var.location
}

# Fetch the AKS cluster if it already exists
data "azurerm_kubernetes_cluster" "existing_aks" {
  name                = var.name
  resource_group_name = var.resource_group_name
}

# AKS Cluster - only create if it doesn't already exist
resource "azurerm_kubernetes_cluster" "aks" {
  count               = data.azurerm_kubernetes_cluster.existing_aks == null ? 1 : 0
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.name}-dns01"
  depends_on = [azurerm_resource_group.rg]

  kubernetes_version = var.k8s_version

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
  }

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = "Standard_A2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Development"
  }
}

