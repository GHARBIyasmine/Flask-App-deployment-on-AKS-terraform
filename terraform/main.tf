# Data block to check if the resource group and AKS cluster exist
data "external" "check_resources" {
  program = ["bash", "check_resources.sh"]

  query = {
    group_name   = var.resource_group_name
    cluster_name = var.name
  }
}

# Resource group creation logic
resource "azurerm_resource_group" "rg" {
  count    = data.external.check_resources.result.group_exists == "true" ? 0 : 1
  name     = var.resource_group_name
  location = var.location
}

# AKS cluster creation logic
resource "azurerm_kubernetes_cluster" "aks" {
  count               = data.external.check_resources.result.aks_exists == "false" ? 1 : 0
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  dns_prefix = "${var.name}-dns01"

  default_node_pool {
    name       = "default"
    vm_size    = "Standard_DS2_v2"
    node_count = var.node_count
  }

  kubernetes_version = var.k8s_version

  identity {
    type = "SystemAssigned"
  }

  depends_on = [azurerm_resource_group.rg]
}
