#!/bin/bash

cluster_name=weatherwatch-api
container_name=extreme-temps
resource_group=weatherwatch

storage_account=$(cat ~/tmp/az-storage-account.txt)
account_key=$(cat ~/tmp/az-storage-account-key.txt)

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
