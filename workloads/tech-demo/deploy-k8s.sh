#!/usr/bin/env bash

JQ_CHECK=`which jq`
if ["$JQ_CHECK" == ""]; then
    echo "Please install jq before running deployment (sudo apt-get install jq, or brew install jq)"
    exit 1
fi

curl -XPOST localhost:7777/v1/files/tech_demo_load_test -F upload=@load-test/locustfile.py
curl -XPOST localhost:7777/v1/files/tech_demo_core_site_xml -F upload=@core-site.xml
curl -XPOST localhost:7777/v1/deployments --data-binary @deploy-k8s.json | jq .
