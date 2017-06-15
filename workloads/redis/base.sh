#!/usr/bin/env bash

DEPLOYER_URL="internal-deployer-605796188.us-east-1.elb.amazonaws.com"
curl -XPOST $DEPLOYER_URL:7777/v1/templates/redis-base --data-binary @base.json
