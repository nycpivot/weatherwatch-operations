#!/bin/bash

cat <<EOF | kubectl apply -f -
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: statestore-web
  namespace: default
spec:
  type: state.redis
  version: v1
  metadata:
  - name: redisHost
    value: dapr-dev-redis-master.default.svc.cluster.local:6379
  - name: redisPassword
    secretKeyRef:
      name: dapr-dev-redis #redis
      key: redis-password
  # uncomment below for connecting to redis cache instances over TLS (ex - Azure Redis Cache)
  # - name: enableTLS
  #   value: true 
EOF
