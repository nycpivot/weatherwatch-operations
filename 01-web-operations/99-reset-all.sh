#!/bin/bash

app_name=weatherwatch-web

aws eks delete-nodegroup --nodegroup-name $app_name-node-group --cluster-name $app_name --no-cli-pager

aws eks delete-cluster --name $app_name --no-cli-pager
