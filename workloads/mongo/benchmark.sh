#!/usr/bin/env bash
curl -XPOST -H "Content-Type: application/json" localhost:7779/benchmarks/mongo -d "{\"deploymentId\":\"$1\", \"startingIntensity\":10, \"step\": 10}"
