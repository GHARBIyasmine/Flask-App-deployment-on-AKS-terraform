#!/bin/bash

# Extract inputs from Terraform
eval "$(jq -r '@sh "GROUP_NAME=\(.group_name) CLUSTER_NAME=\(.cluster_name)"')"

# Check if the resource group exists
group_exists=$(az group exists -n "$GROUP_NAME")
if [ "$group_exists" == "false" ]; then
  aks_exists="false"
else
  aks_exists=$(az aks show --name "$CLUSTER_NAME" --resource-group "$GROUP_NAME" --query "name" --output tsv 2>/dev/null || echo "false")
fi

# Ensure we return proper JSON every time
jq -n --arg group_exists "$group_exists" --arg aks_exists "$aks_exists" \
    '{"group_exists":$group_exists, "aks_exists":$aks_exists}'

echo "Debugging az group exists check..."
echo "GROUP_NAME=${GROUP_NAME}"
echo "Result group_exists=$group_exists aks_exists=$aks_exists"