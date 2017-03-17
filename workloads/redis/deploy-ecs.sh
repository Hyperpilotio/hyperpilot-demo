#!/usr/bin/env bash
curl -XPOST localhost:7777/v1/deployments --data-binary @deploy-ecs.json
