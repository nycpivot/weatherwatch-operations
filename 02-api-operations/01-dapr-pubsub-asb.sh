#!/bin/bash

resource_group=weatherwatch
namespace=weatherwatch
ns=api

connectionString=$(az servicebus namespace authorization-rule keys list --resource-group $resource_group --namespace-name $namespace --name RootManageSharedAccessKey --query primaryConnectionString -o tsv)

cat <<EOF | kubectl apply -n $ns -f -
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: $namespace
spec:
  type: pubsub.azure.servicebus.topics
  version: v1
  metadata:
  - name: connectionString
    value: "$connectionString"
EOF

kubectl get components -n $ns
