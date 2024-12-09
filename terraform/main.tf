# Data block to check if the resource group and AKS cluster exist
data "external" "check_resources" {
  program = ["/bin/bash", "check_resources.sh"]

  query = {
    group_name   = var.resource_group_name
    cluster_name = var.name
  }
}

# Debugging outputs
output "check_resources_debug" {
  value = data.external.check_resources.result
}

resource "azurerm_resource_group" "rg" {
  count    = data.external.check_resources.result.group_exists == "false" ? 1 : 0
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "aks" {
  count               = data.external.check_resources.result.aks_exists == "false" ? 1 : 0
  name                = var.name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg[0].name

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