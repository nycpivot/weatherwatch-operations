#!/bin/bash

resource_group=weatherwatch
asb_namespace=weatherwatch
cluster_name=weatherwatch-api

storage_account=$(cat ~/tmp/az-storage-account.txt)

az servicebus namespace delete --namespace $asb_namespace --resource-group $resource_group
az storage account delete --name $storage_account --resource-group $resource_group
az aks delete --name $cluster_name --resource-group $resource_group

az group delete $resource_group

kubectl config delete-cluster $cluster_name
kubectl config delete-user clusterUser_weatherwatch_$cluster_name
kubectl config delete-context $cluster_name
