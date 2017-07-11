#!/usr/bin/env bash
curl -XPOST -H "Content-Type: application/json" http://internal-profiler-25087965.us-east-1.elb.amazonaws.com:7779/benchmarks/nginx -d "{\"deploymentId\":\"$1\", \"startingIntensity\":10, \"step\": 10}"
