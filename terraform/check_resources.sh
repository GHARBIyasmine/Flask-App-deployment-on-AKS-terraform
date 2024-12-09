#!/bin/bash

az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID

# Extract inputs from Terraform
eval "$(jq -r '@sh "GROUP_NAME=\(.group_name) CLUSTER_NAME=\(.cluster_name)"')"
group_exists=$(az group exists -n "$GROUP_NAME")

# Check if the AKS cluster exists
if [[ "$group_exists" == "true" ]]; then
  aks_exists=$(az aks show --name "$CLUSTER_NAME" --resource-group "$GROUP_NAME" --query "name" --output tsv 2>/dev/null || echo "false")
else
  aks_exists="false"
fi

# Return results as JSON
jq -n --arg group_exists "$group_exists" --arg aks_exists "$aks_exists" \
    '{"group_exists":$group_exists, "aks_exists":$aks_exists}'