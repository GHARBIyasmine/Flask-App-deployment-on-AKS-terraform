#!/bin/bash

# Extract inputs from Terraform
eval "$(jq -r '@sh "GROUP_NAME=\(.group_name) CLUSTER_NAME=\(.cluster_name)"')"

# Check if the resource group exists
group_exists=$(az group exists -n "$GROUP_NAME")

# Check if the AKS cluster exists (only if the resource group exists)
if [[ "$group_exists" == "true" ]]; then
  aks_exists=$(az aks show --name "$CLUSTER_NAME" --resource-group "$GROUP_NAME" --query "name" --output tsv 2>/dev/null || echo "false")
else
  aks_exists="false"
fi

# Suppress all non-JSON output
exec 1>/dev/null 2>/dev/null

# Return results as JSON
jq -n --arg group_exists "$group_exists" --arg aks_exists "$aks_exists" \
    '{"group_exists":$group_exists, "aks_exists":$aks_exists}'
