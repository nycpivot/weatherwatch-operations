#!/bin/bash

resource_group=weatherwatch
asb_namespace=weatherwatch

az servicebus namespace create --name $asb_namespace --resource-group $resource_group --location eastus

