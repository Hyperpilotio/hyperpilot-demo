#!/usr/bin/env bash
#HOST="internal-profiler-25087965.us-east-1.elb.amazonaws.com"
HOST="localhost"
curl -XPOST -H "Content-Type: application/json" http://$HOST:7779/benchmarks/memcached -d "{\"deploymentId\":\"$1\", \"startingIntensity\":10, \"step\": 10}"
