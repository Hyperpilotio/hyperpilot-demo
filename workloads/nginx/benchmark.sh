#!/usr/bin/env bash
curl -XPOST -H "Content-Type: application/json" localhost:7779/benchmarks/nginx -d "{\"deploymentId\":\"$1\", \"startingIntensity\":50, \"step\": 100}"
