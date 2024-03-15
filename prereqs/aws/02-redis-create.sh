#!/bin/bash

cache=weatherwatch-web-cache

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $cache-deployment
  labels:
    app: $cache
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $cache
  template:
    metadata:
      labels:
        app: $cache
    spec:
      containers:
      - name: $cache
        image: redis
---
apiVersion: v1
kind: Service
metadata:
  name: $cache
spec:
  selector:
    app: $cache
  ports:
    - protocol: TCP
      port: 6379
EOF
