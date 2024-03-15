#!/bin/bash

api=weatherwatch-api

image_registry_url=$(az keyvault secret show --name image-registry-url --subscription thejameshome --vault-name cloud-operations-vault --query value --output tsv)
image_registry_username=$(az keyvault secret show --name image-registry-username --subscription thejameshome --vault-name cloud-operations-vault --query value --output tsv)
image_registry_password=$(az keyvault secret show --name image-registry-password --subscription thejameshome --vault-name cloud-operations-vault --query value --output tsv)

cd ~

rm -rf $api

git clone https://github.com/nycpivot/$api -b dapr

cd $api

docker build -t weatherwatch.azurecr.io/$api .

docker login $image_registry_url -u $image_registry_username -p $image_registry_password

docker push $image_registry_url/$api

rm -rf $api
