#!/bin/bash

dns=dapr.api.weatherwatch.live
svc=dapr-dashboard
dapr_ns=dapr-system

cluster_name=weatherwatch-app

kubectl config use-context $cluster_name

dapr init -k --dev

kubectl delete service dapr-dashboard -n dapr-system

cat <<EOF | kubectl apply -n dapr-system -f -
apiVersion: v1
kind: Service
metadata:
  annotations:
    meta.helm.sh/release-name: dapr-dashboard
    meta.helm.sh/release-namespace: dapr-system
  creationTimestamp: "2024-03-17T23:34:06Z"
  labels:
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/name: dapr-dashboard
    app.kubernetes.io/part-of: dapr
    app.kubernetes.io/version: 0.14.0
  name: dapr-dashboard
  namespace: dapr-system
  resourceVersion: "2863"
  uid: 407e27f8-35ca-4a6e-b077-de775ccb0eb2
spec:
  ports:
  - port: 8080
    protocol: TCP
    targetPort: 8080
  selector:
    app: dapr-dashboard
  sessionAffinity: None
  type: LoadBalancer
EOF

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
ipaddress=$(kubectl get svc $svc -n $dapr_ns -o json | jq -r .status.loadBalancer.ingress[].ip)

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

# dapr dashboard -k
