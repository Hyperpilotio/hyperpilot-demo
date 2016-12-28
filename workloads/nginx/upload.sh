#!/usr/bin/env bash
curl -XPOST localhost:7777/v1/files/nginx_load_test -F upload=@load-test/locustfile.py
curl -XPOST localhost:7777/v1/deployments --data-binary @deploy.json
