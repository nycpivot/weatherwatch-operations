#!/bin/bash

data=weatherwatch-data

image_registry_url=$(az keyvault secret show --name image-registry-url --subscription thejameshome --vault-name cloud-operations-vault --query value --output tsv)
image_registry_username=$(az keyvault secret show --name image-registry-username --subscription thejameshome --vault-name cloud-operations-vault --query value --output tsv)
image_registry_password=$(az keyvault secret show --name image-registry-password --subscription thejameshome --vault-name cloud-operations-vault --query value --output tsv)

cd ~

rm -rf $data

git clone https://github.com/nycpivot/$data -b dapr

cd $data

docker build -t weatherwatch.azurecr.io/$data .

docker login $image_registry_url -u $image_registry_username -p $image_registry_password

docker push $image_registry_url/$data

rm -rf $data
