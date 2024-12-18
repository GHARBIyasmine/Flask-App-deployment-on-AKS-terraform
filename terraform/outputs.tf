output "resource_group_name" {
  value = length(azurerm_resource_group.rg) > 0 ? azurerm_resource_group.rg[0].name : var.resource_group_name
}

output "aks_cluster_name" {
  value = length(azurerm_kubernetes_cluster.aks) > 0 ? azurerm_kubernetes_cluster.aks[0].name : var.name
}