# Outputs
output "resource_group_name" {
  value = azurerm_resource_group.rg[0].name
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks[0].name
}
