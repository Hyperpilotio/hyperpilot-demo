#!/usr/bin/env bash

if [ "$#" -lt 1 ]
then
    echo "Usage: deploy-k8s.sh <userId:required>"
    exit 1
fi

FILE_NAME="deploy-k8s.json"

DEPLOYER_URL="localhost"
#DEPLOYER_URL="internal-deployer-605796188.us-east-1.elb.amazonaws.com"

curl -XPOST $DEPLOYER_URL:7777/v1/users/$1/files/mongo_users -F upload=@../../benchmarks/create-dbuser.js
curl -XPOST $DEPLOYER_URL:7777/v1/users/$1/files/configdb -F upload=@../sizing-demo/update_db.sh
curl -XPOST $DEPLOYER_URL:7777/v1/users/$1/files/benchmarks_settings -F upload=@../../benchmarks/collect_benchmarks.py
curl -XPOST $DEPLOYER_URL:7777/v1/users/$1/files/benchmarks_json -F upload=@../../benchmarks/benchmarks.json
curl -XPOST $DEPLOYER_URL:7777/v1/users/$1/files/collect_applications -F upload=@../collect_applications.py
curl -XPOST $DEPLOYER_URL:7777/v1/users/$1/files/analysis_base -F upload=@../common/upload.sh

curl -s -XPOST $DEPLOYER_URL:7777/v1/users/$1/deployments --data-binary @$FILE_NAME

echo "Please check progress of your deployment at http://$DEPLOYER_URL:7777/ui"
