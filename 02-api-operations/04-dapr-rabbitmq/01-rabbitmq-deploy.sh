#!/bin/bash

kubectl config use-context weatherwatch-api

kubectl delete service rabbitmq --ignore-not-found
kubectl delete pod rabbitmq --ignore-not-found

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rabbitmq
  labels:
    app: rabbitmq
spec:
  replicas: 1
  selector:
    matchLabels:
      app: rabbitmq
  template:
    metadata:
      labels:
        app: rabbitmq
    spec:
      containers:
      - name: rabbitmq
        image: "rabbitmq:management"
        ports:
        - name: service
          containerPort: 5672
        - name: portal
          containerPort: 15672
---
apiVersion: v1
kind: Service
metadata:
  name: rabbitmq
spec:
  selector:
    app: rabbitmq
  ports:
    - name: service
      protocol: TCP
      port: 5672
      targetPort: 5672
    - name: portal
      protocol: TCP
      port: 15672
      targetPort: 15672
EOF
