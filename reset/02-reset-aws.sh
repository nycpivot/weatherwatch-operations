#!/bin/bash

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
AWS_REGION_CODE=$(aws configure get region)

vpc_name=default-vpc
weatherwatch_web_cluster=weatherwatch-web
cluster_role_arn=arn:aws:iam::${AWS_ACCOUNT_ID}:role/eks-cluster-role
nodegroup_role_arn=arn:aws:iam::${AWS_ACCOUNT_ID}:role/eks-nodegroup-role
cluster_arn=arn:aws:eks:${AWS_REGION_CODE}:${AWS_ACCOUNT_ID}:cluster

aws eks delete-nodegroup \
    --cluster-name ${weatherwatch_web_cluster} \
    --nodegroup-name ${weatherwatch_web_cluster}-node-group \
    --no-cli-pager

aws eks wait nodegroup-deleted \
    --cluster-name $weatherwatch_web_cluster \
    --nodegroup-name $weatherwatch_web_cluster-node-group

aws eks delete-cluster --name $weatherwatch_web_cluster --no-cli-pager

aws eks wait cluster-deleted --name $weatherwatch_web_cluster

classic_lb1=$(aws elb describe-load-balancers | jq -r .LoadBalancerDescriptions[0].LoadBalancerName)
classic_lb2=$(aws elb describe-load-balancers | jq -r .LoadBalancerDescriptions[1].LoadBalancerName)
# network_lb1=$(aws elbv2 describe-load-balancers | jq -r .LoadBalancers[0].LoadBalancerArn)
# network_lb2=$(aws elbv2 describe-load-balancers | jq -r .LoadBalancers[1].LoadBalancerArn)

aws elb delete-load-balancer --load-balancer-name $classic_lb1
echo

aws elb delete-load-balancer --load-balancer-name $classic_lb2
echo

# aws elbv2 delete-load-balancer --load-balancer-arn $network_lb1
# echo

# aws elbv2 delete-load-balancer --load-balancer-arn $network_lb2
# echo

kubectl config delete-cluster arn:aws:eks:$AWS_REGION_CODE:$AWS_ACCOUNT_ID:cluster/$weatherwatch_web_cluster
kubectl config delete-user arn:aws:eks:$AWS_REGION_CODE:$AWS_ACCOUNT_ID:cluster/$weatherwatch_web_cluster
kubectl config delete-context $weatherwatch_web_cluster
