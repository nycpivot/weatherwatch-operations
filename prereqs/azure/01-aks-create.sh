#!/bin/bash

resource_group=weatherwatch
cluster_name=weatherwatch-app
aks_region_code=eastus
vault_name=cloud-operations-vault

ns_api=api
ns_data=data
ns_eso=external-secrets

# create resource group
az group create --name ${resource_group} --location ${aks_region_code}

# create aks cluster
az aks create --name ${cluster_name} --resource-group ${resource_group} \
	--node-count 2 --node-vm-size Standard_B2ms --kubernetes-version 1.28.5 \
	--enable-managed-identity --enable-addons monitoring \
	--enable-msi-auth-for-monitoring --generate-ssh-keys 

az aks get-credentials --name ${cluster_name} --resource-group ${resource_group}

kubectl create namespace $ns_api
kubectl create namespace $ns_data

# helm install external-secrets external-secrets/external-secrets -n $ns_eso --create-namespace

# tenantId=$(az account show --query tenantId | tr -d \")
# vaultUrl=$(az keyvault show --name $vault_name | jq -r .properties.vaultUri)
# appId=$(az ad app create --display-name "external-secret-operator" --query appId | tr -d \")
# sp=$(az ad sp create --id $appId --query id | tr -d \")
# p=$(az ad app credential reset --id $appId --query password | tr -d \")

# # save these off for deleting later in reset script
# echo $appId > ~/tmp/eso-appid.txt
# echo $sp > ~/tmp/eso-sp.txt
# # echo $p > ~/tmp/eso-p.txt

# kubectl create secret generic azure-secret-sp -n $ns_eso \
# 	--from-literal=ClientID=$appId \
# 	--from-literal=ClientSecret=$p

# cat <<EOF | kubectl apply -n $ns_eso -f -
# apiVersion: external-secrets.io/v1beta1
# kind: SecretStore
# metadata:
#   name: az-keyvault
# spec:
#   provider:
#     azurekv:
#       tenantId: "$tenantId"
#       vaultUrl: "$vaultUrl"
#       authSecretRef:
#         clientId:
#           name: azure-secret-sp
#           key: ClientID
#         clientSecret:
#           name: azure-secret-sp
#           key: ClientSecret
# EOF

# cat <<EOF | kubectl apply -n $ns_eso -f -
# apiVersion: external-secrets.io/v1beta1
# kind: ExternalSecret
# metadata:
#   name: external-secret
# spec:
#   refreshInterval: "1h"
#   secretStoreRef:
#     kind: SecretStore
#     name: az-keyvault
#   target:
#     name: weather-bit-api
#     creationPolicy: Owner
#   data:
#   - secretKey: url
#     remoteRef:
#       key: cloud-operations-vault
#       property: weather-bit-api-url
#   - secretKey: key
#     remoteRef:
#       key: cloud-operations-vault
#       property: weather-bit-api-key
# EOF
