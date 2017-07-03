#!/usr/bin/env bash
curl -XPOST -H "Content-Type: application/json" localhost:7779/calibrate/nginx -d "{\"deploymentId\":\"$1\"}"
