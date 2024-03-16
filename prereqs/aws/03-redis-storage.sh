#!/bin/bash

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
AWS_REGION_CODE=$(aws configure get region)

storage_class_name=web-cache

# SC
cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: $storage_class_name
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
reclaimPolicy: Retain
allowVolumeExpansion: true
EOF

# PV
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: redis-data-redis-cluster-master-0
spec:
  storageClassName: $storage_class_name
  capacity:
    storage: 8Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /mnt/redis-cluster-master-0
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: redis-data-redis-cluster-slave-0
spec:
  storageClassName: $storage_class_name
  capacity:
    storage: 8Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /mnt/redis-cluster-slave-0
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: redis-data-redis-cluster-slave-1
spec:
  storageClassName: $storage_class_name
  capacity:
    storage: 8Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /mnt/redis-cluster-slave-1
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: redis-data-redis-cluster-slave-2
spec:
  storageClassName: $storage_class_name
  capacity:
    storage: 8Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /mnt/redis-cluster-slave-2
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: redis-data-redis-cluster-slave-3
spec:
  storageClassName: $storage_class_name
  capacity:
    storage: 8Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /mnt/redis-cluster-slave-3
EOF
