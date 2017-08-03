#!/usr/bin/env bash

if [ "$#" -lt 1 ]
then
    echo "Usage: deploy-k8s.sh <userId:required>"
    exit 1
fi

FILE_NAME="deploy-k8s.json"

DEPLOYER_URL="localhost"
#DEPLOYER_URL="internal-deployer-605796188.us-east-1.elb.amazonaws.com"
curl -s -XPOST $DEPLOYER_URL:7777/v1/users/$1/deployments --data-binary @$FILE_NAME
echo "Please check progress of your deployment at http://$DEPLOYER_URL:7777/ui"
