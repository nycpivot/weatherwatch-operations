#!/bin/bash

resource_group=weatherwatch
asb_namespace=weatherwatch
weatherwatch_api_cluster=weatherwatch-api

az servicebus delete --namespace $asb_namespace --resource-group $resource_group
az aks delete --name $weatherwatch_api_cluster --resource-group $resource_group

az group delete $resource_group