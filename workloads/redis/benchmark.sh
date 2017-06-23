#!/usr/bin/env bash

#PROFILER_URL="internal-profiler-25087965.us-east-1.elb.amazonaws.com"
PROFILER_URL="localhost"

curl -XPOST -H "Content-Type: application/json" $PROFILER_URL:7779/benchmarks/redis -d "{\"startingIntensity\":25, \"step\": 25}"

echo "Please check progress of your deployment at http://$PROFILER_URL:7779/ui"


