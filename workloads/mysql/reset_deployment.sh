#!/bin/bash

DEPLOYMENT_NAME=$1

if [ -z "$1" ]; then
    DEPLOYMENT_NAME=`kubectl get nodes --show-labels | grep deployment | tr "," "\n" | grep deployment | head -n 1 | cut -d"=" -f2`

    if [ -z "$DEPLOYMENT_NAME" ]; then
        echo "Unable to find or detect deployment name"
        exit 1
    fi

fi

DEPLOYER_URL="localhost"
#DEPLOYER_URL="internal-deployer-605796188.us-east-1.elb.amazonaws.com"

echo "Resetting demo with deployment $DEPLOYMENT_NAME"

curl -XPUT $DEPLOYER_URL:7777/v1/deployments/$DEPLOYMENT_NAME --data-binary @deploy-k8s.json
