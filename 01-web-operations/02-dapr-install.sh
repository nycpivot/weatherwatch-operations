#!/bin/bash

dns=dapr.weatherwatch.live
svc=dapr-dashboard
dapr_ns=dapr-system

kubectl config use-context weatherwatch-web

dapr init -k --dev

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
  clusterIP: 10.100.92.96
  clusterIPs:
  - 10.100.92.96
  internalTrafficPolicy: Cluster
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8080
  selector:
    app: dapr-dashboard
  sessionAffinity: None
  type: LoadBalancer
EOF

sleep 20

# dns
hosted_zone_id=$(aws route53 list-hosted-zones --query HostedZones[2].Id --output text | awk -F '/' '{print $3}')
ingress=$(kubectl get svc $svc -n $dapr_ns -o json | jq -r .status.loadBalancer.ingress[].hostname)

change_batch_filename=change-batch-$RANDOM
cat <<EOF | tee $change_batch_filename.json
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
    --change-batch file:///$HOME/$change_batch_filename.json

rm $change_batch_filename.json
echo

dapr dashboard -k
