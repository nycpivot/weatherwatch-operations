#!/bin/bash

cluster_name=weatherwatch-api

kubectl config use-context $cluster_name

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
kind: Component
metadata:
  name: weatherwatch
spec:
  type: pubsub.rabbitmq
  version: v1
  metadata:
  - name: connectionString
    value: "amqp://localhost:5672"
  - name: protocol
    value: amqp
  - name: hostname
    value: localhost
  - name: username
    value: guest
  - name: password
    value: guest
  - name: durable
    value: "false"
  - name: deletedWhenUnused
    value: "false"
  - name: autoAck
    value: "false"
  - name: reconnectWait
    value: "0"
  - name: concurrency
    value: parallel
scopes:
- coldestday
- hottestday
EOF

kubectl get components
