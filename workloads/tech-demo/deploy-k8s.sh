#!/usr/bin/env bash

DEPLOYER_URL="localhost"
USER_ID="william"
# DEPLOYER_URL="internal-deployer-605796188.us-east-1.elb.amazonaws.com"

curl -XPOST $DEPLOYER_URL:7777/v1/users/$USER_ID/files/tech_demo_load_test -F upload=@load-test/slow_cooker.py
curl -XPOST $DEPLOYER_URL:7777/v1/users/$USER_ID/files/tech_demo_core_site_xml -F upload=@core-site.xml
curl -s -XPOST $DEPLOYER_URL:7777/v1/deployments --data-binary @deploy-k8s.json

echo "Please check progress of your deployment at http://$DEPLOYER_URL:7777/ui"
