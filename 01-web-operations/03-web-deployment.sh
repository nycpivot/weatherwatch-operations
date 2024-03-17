#!/bin/bash

web=weatherwatch-web
dns=weatherwatch.live

image_registry_url=$(az keyvault secret show --name image-registry-url --subscription thejameshome --vault-name cloud-operations-vault --query value --output tsv)
image_registry_username=$(az keyvault secret show --name image-registry-username --subscription thejameshome --vault-name cloud-operations-vault --query value --output tsv)
image_registry_password=$(az keyvault secret show --name image-registry-password --subscription thejameshome --vault-name cloud-operations-vault --query value --output tsv)

weather_api_url=http://api.weatherwatch.live

cd ~

#docker login $image_registry_url -u $image_registry_username -p $image_registry_password

kubectl config use-context $web

kubectl delete secret $web-secret --ignore-not-found

kubectl create secret docker-registry $web-secret \
	--docker-server=$image_registry_url \
	--docker-username=$image_registry_username \
	--docker-password=$image_registry_password

cat <<EOF | tee $web-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $web-deployment
  labels:
    app: $web
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $web
  template:
    metadata:
      labels:
        app: $web
      annotations:
        dapr.io/enabled: "true"
        dapr.io/app-id: "$api"
        dapr.io/app-port: "8080"
        dapr.io/log-level: "debug"
        dapr.io/enable-api-logging: "true"
    spec:
      containers:
      - name: $web
        image: weatherwatch.azurecr.io/$web
        env:
        - name: WEATHER_API
          value: $weather_api_url 
        ports:
        - containerPort: 8080
      imagePullSecrets:
      - name: $web-secret
---
apiVersion: v1
kind: Service
metadata:
  name: $web
spec:
  selector:
    app: $web
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
  type: LoadBalancer
EOF

kubectl delete -f $web-deployment.yaml --ignore-not-found

kubectl apply -f $web-deployment.yaml

rm $web-deployment.yaml

echo
ctr=20
while [ $ctr -gt 0 ]
do
echo "Waiting ${ctr} seconds for service..."
sleep 5 # give 15 minutes for all clusters to be created
ctr=`expr $ctr - 5`
done

# dns
hosted_zone_id=$(aws route53 list-hosted-zones --query HostedZones[2].Id --output text | awk -F '/' '{print $3}')
ingress=$(kubectl get svc $web -o json | jq -r .status.loadBalancer.ingress[].hostname)

echo
echo "Waiting for DNS to propagate..."
echo

ipaddress=''
while [[ $ipaddress == '' ]]
do
ipaddress=$(dig +short $ingress | head -n 1)
sleep 5
done

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
