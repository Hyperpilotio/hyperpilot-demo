#!/usr/bin/env bash
curl -XPOST -H "Content-Type: application/json" $1/benchmarks/lucene -d "{\"startingIntensity\":10, \"step\": 10}"
