#!/usr/bin/env bash

if [ "$#" -ne 1 ]
then
    echo "Usage: deploy-gcp.sh <userId>"
    exit 1
fi

SERVICE_ACCOUNT_FILE="gcpServiceAccount.json"
if [ -f "$SERVICE_ACCOUNT_FILE" ]
then
	echo "$SERVICE_ACCOUNT_FILE found."
else
	echo "$SERVICE_ACCOUNT_FILE not found."
    exit 1
fi

#DEPLOYER_URL="internal-deployer-605796188.us-east-1.elb.amazonaws.com"
DEPLOYER_URL="localhost"

curl -XPOST $DEPLOYER_URL:7777/v1/users/$1/files/gcpServiceAccount_json -F upload=@$SERVICE_ACCOUNT_FILE
curl -XPOST $DEPLOYER_URL:7777/v1/users/$1/deployments --data-binary @deploy-gcp.json

echo "Please check progress of your deployment at http://$DEPLOYER_URL:7777/ui"
