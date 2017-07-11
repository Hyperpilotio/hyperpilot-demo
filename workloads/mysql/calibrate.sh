#!/usr/bin/env bash

#DEPLOYER_URL="internal-deployer-605796188.us-east-1.elb.amazonaws.com"
DEPLOYER_URL="localhost"

curl -XPOST -H "Content-Type: application/json" http://internal-profiler-25087965.us-east-1.elb.amazonaws.com:7779/calibrate/mysql -d "{\"deploymentId\":\"$1\"}"
