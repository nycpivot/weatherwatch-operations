#!/bin/bash

resource_group=weatherwatch
asb_namespace=weatherwatch

# create azure service bus (let dapr create the topic)
az servicebus namespace create \
    --name $asb_namespace --resource-group $resource_group --location eastus