#!/usr/bin/env bash

if [ "$#" -lt 1 ]
then
    echo "Usage: deploy-k8s.sh <userId:required> <mode:optional>"
    exit 1
fi

if [ "-$2" = "-" ]; then
  MODE=""
else
  MODE="-$2"
fi

FILE_NAME="deploy-k8s$MODE.json"

DEPLOYER_URL="localhost"
#DEPLOYER_URL="internal-deployer-605796188.us-east-1.elb.amazonaws.com"

curl -XPOST $DEPLOYER_URL:7777/v1/users/$1/files/tech_demo_load_test -F upload=@load-test/locustfile.py
curl -XPOST $DEPLOYER_URL:7777/v1/users/$1/files/tech_demo_core_site_xml -F upload=@core-site.xml
curl -XPOST $DEPLOYER_URL:7777/v1/users/$1/files/telegraf_config -F upload=@telegraf.conf
curl -s -XPOST $DEPLOYER_URL:7777/v1/users/$1/deployments --data-binary @$FILE_NAME

echo "Please check progress of your deployment at http://$DEPLOYER_URL:7777/ui"
