#!/usr/bin/env bash

USER_ID=$1
if [ "$USER_ID" == "" ]; then
    echo "Please input userId (./deploy-k8s.sh yourUserId)"
    exit 1
fi

#DEPLOYER_URL="localhost"
DEPLOYER_URL="internal-deployer-605796188.us-east-1.elb.amazonaws.com"

curl -XPOST $DEPLOYER_URL:7777/v1/users/$USER_ID/files/tech_demo_load_test -F upload=@load-test/locustfile.py
curl -XPOST $DEPLOYER_URL:7777/v1/users/$USER_ID/files/tech_demo_core_site_xml -F upload=@core-site.xml
curl -s -XPOST $DEPLOYER_URL:7777/v1/users/$USER_ID/deployments --data-binary @deploy-k8s.json

echo "Please check progress of your deployment at http://$DEPLOYER_URL:7777/ui"
