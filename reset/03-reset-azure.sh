#!/bin/bash

resource_group=weatherwatch
asb_namespace=weatherwatch
weatherwatch_api_cluster=weatherwatch-api

storage_account=$(cat ~/weatherwatch-dapr-ops/az-storage-account.txt)

az servicebus namespace delete --namespace $asb_namespace --resource-group $resource_group
az storage account delete --name $storage_account --resource-group $resource_group
az aks delete --name $weatherwatch_api_cluster --resource-group $resource_group

az group delete $resource_group

kubectl config delete-cluster arn:aws:eks:$AWS_REGION_CODE:$AWS_ACCOUNT_ID:cluster/$weatherwatch_web_cluster
kubectl config delete-user arn:aws:eks:$AWS_REGION_CODE:$AWS_ACCOUNT_ID:cluster/$weatherwatch_web_cluster
kubectl config delete-context $weatherwatch_web_cluster
