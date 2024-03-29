#!/bin/bash

dns=dapr.weatherwatch.live
svc=dapr-dashboard
dapr_ns=dapr-system

kubectl config use-context weatherwatch-web

dapr init -k --dev

kubectl delete service dapr-dashboard -n dapr-system

cat <<EOF | kubectl apply -n dapr-system -f -
apiVersion: v1
kind: Service
metadata:
  annotations:
    meta.helm.sh/release-name: dapr-dashboard
    meta.helm.sh/release-namespace: dapr-system
  creationTimestamp: "2024-03-14T19:24:56Z"
  labels:
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/name: dapr-dashboard
    app.kubernetes.io/part-of: dapr
    app.kubernetes.io/version: 0.14.0
  name: dapr-dashboard
  namespace: dapr-system
  resourceVersion: "18095"
  uid: da493b0c-448a-4b4a-aa2e-636e515bc835
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8080
  selector:
    app: dapr-dashboard
  sessionAffinity: None
  type: LoadBalancer
EOF

echo
echo "Waiting for service IP hostname..."
echo

kubectl get service $svc -n $dapr_ns -w
echo

# dns
hosted_zone_id=Z0606413QB4B75CQOQ5P # $(aws route53 list-hosted-zones --query HostedZones[2].Id --output text | awk -F '/' '{print $3}')
ingress=$(kubectl get svc $svc -n $dapr_ns -o json | jq -r .status.loadBalancer.ingress[].hostname)

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
                "Type": "CNAME",
                "TTL": 60,
                "ResourceRecords": [
                    {
                        "Value": "${ingress}"
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

# dapr dashboard -k
