#!/usr/bin/env bash
curl -XPOST localhost:7777/v1/files/nodejs_load_test -F upload=@load-test/locustfile.py
curl -XPOST localhost:7777/v1/deployments --data-binary @deploy-ecs.json
