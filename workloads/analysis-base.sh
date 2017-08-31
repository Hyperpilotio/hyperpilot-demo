#!/usr/bin/env bash

DEPLOYER_URL="localhost"
curl -XPOST $DEPLOYER_URL:7777/v1/templates/analysis-base --data-binary @analysis-base.json
