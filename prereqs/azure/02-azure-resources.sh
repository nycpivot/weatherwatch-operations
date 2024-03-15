#!/bin/bash

resource_group=weatherwatch
cluster_name=weatherwatch-api
aks_region_code=eastus
asb_namespace=weatherwatch
storage_account=weatherwatch$RANDOM
container_name=extreme-temps

# create resource group
az group create --name ${resource_group} --location ${aks_region_code}

# create aks cluster
az aks create --name ${cluster_name} --resource-group ${resource_group} \
	    --node-count 2 --node-vm-size Standard_B2ms --kubernetes-version 1.28.5 \
	        --enable-managed-identity --enable-addons monitoring --enable-msi-auth-for-monitoring --generate-ssh-keys 

az aks get-credentials --name ${cluster_name} --resource-group ${resource_group}

# create azure service bus (let dapr create the topic)
az servicebus namespace create \
    --name $asb_namespace --resource-group $resource_group --location eastus

# save storage account name (random)
echo $storage_account > ~/weatherwatch-dapr-ops/az-storage-account.txt

# create storage account and container
az storage account create --name $storage_account --resource-group $resource_group

az storage container create --name $container_name --account-name $storage_account

account_key=$(az storage account keys list --account-name $storage_account | jq -r .[0].value)

# save storage account key for dapr component
echo $account_key > ~/weatherwatch-dapr-ops/az-storage-account-key.txt
