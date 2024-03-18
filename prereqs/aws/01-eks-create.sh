#!/bin/bash

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
AWS_REGION_CODE=$(aws configure get region)

vpc_name=default-vpc
weatherwatch_web_cluster=weatherwatch-web
cluster_role_arn=arn:aws:iam::$AWS_ACCOUNT_ID:role/eks-cluster-role
nodegroup_role_arn=arn:aws:iam::$AWS_ACCOUNT_ID:role/eks-nodegroup-role
cluster_arn=arn:aws:eks:${AWS_REGION_CODE}:$AWS_ACCOUNT_ID:cluster

vpc_id=$(aws ec2 describe-vpcs --query "Vpcs[?Tags[?Value=='$vpc_name']].VpcId" --output text)
subnetIds=$(aws ec2 describe-subnets --query "Subnets[?VpcId=='$vpc_id'].SubnetId" --output text)

subnetId1=$(echo $subnetIds | awk -F ' ' '{print $1}')
subnetId2=$(echo $subnetIds | awk -F ' ' '{print $2}')
subnetId3=$(echo $subnetIds | awk -F ' ' '{print $3}')
subnetId4=$(echo $subnetIds | awk -F ' ' '{print $4}')
subnetId5=$(echo $subnetIds | awk -F ' ' '{print $5}')
subnetId6=$(echo $subnetIds | awk -F ' ' '{print $6}')

aws eks create-cluster \
	--name $weatherwatch_web_cluster \
	--region $AWS_REGION_CODE \
	--kubernetes-version 1.28 \
	--role-arn $cluster_role_arn \
	--resources-vpc-config subnetIds=$subnetId3,$subnetId6 \
	--no-cli-pager

aws eks wait cluster-active --name $weatherwatch_web_cluster

aws eks create-nodegroup \
	--cluster-name $weatherwatch_web_cluster \
	--nodegroup-name "${weatherwatch_web_cluster}-node-group" \
	--disk-size 50 \
	--scaling-config minSize=1,maxSize=3,desiredSize=1 \
	--subnets "$subnetId3" "$subnetId6" \
	--instance-types t3.medium \
	--node-role $nodegroup_role_arn \
	--kubernetes-version 1.28 \
	--no-cli-pager

aws eks wait nodegroup-active \
	--cluster-name $weatherwatch_web_cluster \
	--nodegroup-name ${weatherwatch_web_cluster}-node-group

aws eks update-kubeconfig --name ${weatherwatch_web_cluster} --region ${AWS_REGION_CODE}

kubectl config rename-context ${cluster_arn}/${weatherwatch_web_cluster} ${weatherwatch_web_cluster}
