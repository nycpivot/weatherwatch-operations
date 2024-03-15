#!/bin/bash

cluster_name=weatherwatch-api
storage_account=weatherwatch$RANDOM
container_name=extreme-temps
resource_group=weatherwatch

az storage account create --name $storage_account --resource-group $resource_group

az storage container create --name $container_name --account-name $storage_account

account_key=$(az storage account keys list --account-name $storage_account | jq -r .[0].value)

kubectl config use-context $cluster_name

cat <<EOF | kubectl apply -f -
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: weatherwatch-extremetemps
spec:
  type: state.azure.blobstorage
  version: v2
  metadata:
  - name: accountName
    value: "$storage_account"
  - name: accountKey
    value: "$account_key"
  - name: containerName
    value: "$container_name"
EOF

kubectl get components
