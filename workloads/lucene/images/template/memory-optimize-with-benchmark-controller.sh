#!/usr/bin/env bash

DEPLOYER_URL="localhost"
curl -XPOST $DEPLOYER_URL:7777/v1/templates/memory-optimize --data-binary @memory-optimize-with-benchmark-controller.json
