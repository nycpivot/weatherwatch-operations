#!/bin/bash

kubectl config use-context weatherwatch-api

dapr init -k --dev

dapr dashboard -k
