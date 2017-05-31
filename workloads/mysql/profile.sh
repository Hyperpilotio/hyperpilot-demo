#!/usr/bin/env bash
curl -XPOST $DEPLOYER_URL:7779/profilers/deployments/$1 --data-binary @profile.json
