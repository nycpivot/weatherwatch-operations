#!/bin/bash

data=weatherwatch-data
dns=data.weatherwatch.live

app_name=weatherwatch-data
image_registry_url=$(az keyvault secret show --name image-registry-url --subscription thejameshome --vault-name cloud-operations-vault --query value --output tsv)
image_registry_username=$(az keyvault secret show --name image-registry-username --subscription thejameshome --vault-name cloud-operations-vault --query value --output tsv)
image_registry_password=$(az keyvault secret show --name image-registry-password --subscription thejameshome --vault-name cloud-operations-vault --query value --output tsv)

cd ~

kubectl config use-context weatherwatch-api

kubectl delete secret weatherwatch-api-secret --ignore-not-found

kubectl create secret docker-registry weatherwatch-api-secret \
	--docker-server=$image_registry_url \
	--docker-username=$image_registry_username \
	--docker-password=$image_registry_password

cat <<EOF | tee $data-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $data-deployment
  labels:
    app: $data
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $data
  template:
    metadata:
      labels:
        app: $data
      annotations:
        dapr.io/enabled: "true"
        dapr.io/app-id: "$data"
        dapr.io/app-port: "8080"
        dapr.io/log-level: "debug"
        dapr.io/enable-api-logging: "true"
    spec:
      containers:
      - name: $data
        image: weatherwatch.azurecr.io/$data
        ports:
        - containerPort: 8080
      imagePullSecrets:
      - name: weatherwatch-api-secret
---
apiVersion: v1
kind: Service
metadata:
  name: $data
spec:
  selector:
    app: $data
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
  type: LoadBalancer
EOF

kubectl delete -f $data-deployment.yaml --ignore-not-found

kubectl apply -f $data-deployment.yaml

rm $data-deployment.yaml

sleep 20

# dns
hosted_zone_id=$(aws route53 list-hosted-zones --query HostedZones[2].Id --output text | awk -F '/' '{print $3}')
ingress=$(kubectl get svc $data -o json | jq -r .status.loadBalancer.ingress[].ip)

ipaddress=$ingress

change_batch_filename=change-batch-$RANDOM
cat <<EOF | tee $change_batch_filename.json
{
    "Comment": "Update record.",
    "Changes": [
        {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "$dns",
                "Type": "A",
                "TTL": 60,
                "ResourceRecords": [
                    {
                        "Value": "${ipaddress}"
                    }
                ]
            }
        }
    ]
}
EOF
echo

aws route53 change-resource-record-sets \
  --hosted-zone-id $hosted_zone_id \
  --change-batch file:///$HOME/$change_batch_filename.json

rm $change_batch_filename.json
echo

kubectl get pods
echo

kubectl get services
echo
