#!/bin/bash

resource_group=weatherwatch
cluster_name=weatherwatch-app
aks_region_code=eastus

# create resource group
az group create --name ${resource_group} --location ${aks_region_code}

# create aks cluster
az aks create --name ${cluster_name} --resource-group ${resource_group} \
	    --node-count 1 --node-vm-size Standard_B2ms --kubernetes-version 1.28.5 \
	        --enable-managed-identity --enable-addons monitoring --enable-msi-auth-for-monitoring --generate-ssh-keys 

az aks get-credentials --name ${cluster_name} --resource-group ${resource_group}

kubectl create namespace api
kubectl create namespace data
