#!/bin/bash

web=weatherwatch-web

image_registry_url=$(az keyvault secret show --name image-registry-url --subscription thejameshome --vault-name cloud-operations-vault --query value --output tsv)
image_registry_username=$(az keyvault secret show --name image-registry-username --subscription thejameshome --vault-name cloud-operations-vault --query value --output tsv)
image_registry_password=$(az keyvault secret show --name image-registry-password --subscription thejameshome --vault-name cloud-operations-vault --query value --output tsv)

cd ~

git clone https://github.com/nycpivot/$web -b dapr

cd ~/$web

docker build -t weatherwatch.azurecr.io/$web .

docker login $image_registry_url -u $image_registry_username -p $image_registry_password

docker push $image_registry_url/$web

rm -rf ~/$web
