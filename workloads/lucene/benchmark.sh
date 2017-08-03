#!/usr/bin/env bash
curl -XPOST -H "Content-Type: application/json" http://a520076947b1b11e7b59902ef0b3ad99-1398447323.us-east-1.elb.amazonaws.com:7779/benchmarks/lucene -d "{\"startingIntensity\":10, \"step\": 10}"
