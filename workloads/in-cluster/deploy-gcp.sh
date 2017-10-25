#!/usr/bin/env bash

if [ "$#" -lt 1 ]
then
    echo "Usage: deploy-gcp.sh <userId>"
    exit 1
fi

DEPLOYER_URL="localhost"
#DEPLOYER_URL="internal-deployer-605796188.us-east-1.elb.amazonaws.com"

FILE_NAME="deploy-gcp.json"

curl -XPOST $DEPLOYER_URL:7777/v1/users/$1/files/gcpServiceAccount_json -F upload=@${HOME}/gcpServiceAccount.json
curl -s -XPOST $DEPLOYER_URL:7777/v1/users/$1/deployments --data-binary @$FILE_NAME

echo "Please check progress of your deployment at http://$DEPLOYER_URL:7777/ui"
