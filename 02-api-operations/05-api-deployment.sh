#!/bin/bash

api=weatherwatch-api
dns=api.weatherwatch.live

image_registry_url=$(az keyvault secret show --name image-registry-url --subscription thejameshome --vault-name cloud-operations-vault --query value --output tsv)
image_registry_username=$(az keyvault secret show --name image-registry-username --subscription thejameshome --vault-name cloud-operations-vault --query value --output tsv)
image_registry_password=$(az keyvault secret show --name image-registry-password --subscription thejameshome --vault-name cloud-operations-vault --query value --output tsv)

weather_bit_api_url=$(az keyvault secret show --name weather-bit-api-url --subscription thejameshome --vault-name cloud-operations-vault --query value --output tsv)
weather_bit_api_key=$(az keyvault secret show --name weather-bit-api-key --subscription thejameshome --vault-name cloud-operations-vault --query value --output tsv)

weather_data_api=http://data.weatherwatch.live

cd ~

kubectl config use-context $api

kubectl delete secret $api-secret --ignore-not-found

kubectl create secret docker-registry $api-secret \
	--docker-server=$image_registry_url \
	--docker-username=$image_registry_username \
	--docker-password=$image_registry_password

cat <<EOF | tee $api-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $api-deployment
  labels:
    app: $api
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $api
  template:
    metadata:
      labels:
        app: $api
      annotations:
        dapr.io/enabled: "true"
        dapr.io/app-id: "$api"
        dapr.io/app-port: "8080"
        dapr.io/log-level: "debug"
        dapr.io/enable-api-logging: "true"
    spec:
      containers:
      - name: $api
        image: weatherwatch.azurecr.io/$api
        env:
        - name: WEATHER_DATA_API_URL
          value: $weather_data_api
        - name: WEATHER_BIT_API_URL
          value: $weather_bit_api_url
        - name: WEATHER_BIT_API_KEY
          value: $weather_bit_api_key 
        ports:
        - containerPort: 8080
      imagePullSecrets:
      - name: $api-secret
---
apiVersion: v1
kind: Service
metadata:
  name: $api
spec:
  selector:
    app: $api
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
  type: LoadBalancer
EOF

kubectl delete -f $api-deployment.yaml --ignore-not-found

kubectl apply -f $api-deployment.yaml

rm $api-deployment.yaml

sleep 20

# dns
hosted_zone_id=$(aws route53 list-hosted-zones --query HostedZones[2].Id --output text | awk -F '/' '{print $3}')
ingress=$(kubectl get svc $api -o json | jq -r .status.loadBalancer.ingress[].ip)

ipaddress=$ingress

change_batch_filename=change-batch-$RANDOM
cat <<EOF | tee ~/tmp/$change_batch_filename.json
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
  --change-batch file:///$HOME/tmp/$change_batch_filename.json

rm ~/tmp/$change_batch_filename.json
echo

kubectl get pods
echo

kubectl get services
echo
