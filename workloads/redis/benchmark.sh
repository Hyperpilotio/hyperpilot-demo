#!/usr/bin/env bash
curl -XPOST -H "Content-Type: application/json" localhost:7779/benchmarks/redis -d "{\"deploymentId\":\"$1\", \"startingIntensity\":25, \"step\": 25}"
