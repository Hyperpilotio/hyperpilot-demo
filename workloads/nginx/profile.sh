#!/usr/bin/env bash

curl -XPOST localhost:7779/profilers/deployments/$1 --data-binary @profile.json
