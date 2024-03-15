#!/bin/bash

kubectl config use-context weatherwatch-web

dapr init -k --dev

dapr dashboard -k
