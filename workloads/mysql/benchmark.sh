#!/usr/bin/env bash

DEPLOYER_URL="http://internal-profiler-25087965.us-east-1.elb.amazonaws.com:7779"
#DEPLOYER_URL="localhost"

curl -XPOST -H "Content-Type: application/json" $DEPLOYER_URL/benchmarks/mysql -d "{\"deploymentId\":\"$1\", \"startingIntensity\":10, \"step\": 10}"
