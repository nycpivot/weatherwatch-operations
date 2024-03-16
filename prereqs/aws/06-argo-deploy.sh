#!/bin/bash

kubectl create namespace argocd

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.10.3/manifests/install.yaml
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/manifests/install.yaml

cat <<EOF | kubectl apply -n argocd -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: weatherwatch-web
  namespace: argocd
  finalizers:
  - resources-finalizer.argocd.argoproj.io
  annotations:
    argocd-image-updater.argoproj.io/image-list: vfarcic/
EOF
