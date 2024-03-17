#!/bin/bash

resource_group=weatherwatch
storage_account=weatherwatch$RANDOM
container_name=extreme-temps

# save storage account name (random)
echo $storage_account > ~/weatherwatch-dapr-ops/az-storage-account.txt

# create storage account and container
az storage account create --name $storage_account --resource-group $resource_group

az storage container create --name $container_name --account-name $storage_account

account_key=$(az storage account keys list --account-name $storage_account | jq -r .[0].value)

# save storage account key for dapr component
echo $account_key > ~/tmp/az-storage-account-key.txt
