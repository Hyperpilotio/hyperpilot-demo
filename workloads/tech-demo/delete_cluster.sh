#!/usr/bin/env bash

curl -XDELETE localhost:7777/v1/deployments/$1

# Ignore if folder doesn't exist
`rm -rf /tmp/deployer-$1`
