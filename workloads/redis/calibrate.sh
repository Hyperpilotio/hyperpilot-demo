#!/usr/bin/env bash
curl -XPOST -H "Content-Type: application/json" http://internal-profiler-25087965.us-east-1.elb.amazonaws.com:7779/calibrate/redis -d "{\"deploymentId\":\"$1\"}"
