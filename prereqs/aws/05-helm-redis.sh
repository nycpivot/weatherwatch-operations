#!/bin/bash

helm repo add bitnami https://charts.bitnami.com/bitnami

cat <<EOF | tee ~/tmp/custom-redis.yaml
master:
  password: "P@ssw0rd#01"
persistence:
  enabled: true
volumePermissions:
  enabled: true
securityContext:
  enabled: true
  fsGroup: 1001
  runAsUser: 1001
EOF

helm install redis bitnami/redis -f ~/tmp/custom-redis.yaml


# cache=weatherwatch-web-cache

# cat <<EOF | kubectl apply -f -
# apiVersion: apps/v1
# kind: Deployment
# metadata:
#   name: $cache-deployment
#   labels:
#     app: $cache
# spec:
#   replicas: 1
#   selector:
#     matchLabels:
#       app: $cache
#   template:
#     metadata:
#       labels:
#         app: $cache
#     spec:
#       containers:
#       - name: $cache
#         image: redis
# ---
# apiVersion: v1
# kind: Service
# metadata:
#   name: $cache
# spec:
#   selector:
#     app: $cache
#   ports:
#     - protocol: TCP
#       port: 6379
# EOF
