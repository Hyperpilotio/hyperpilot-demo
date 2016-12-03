#!/usr/bin/env bash

if [[ "{$AWS_REGION}X" == "X" ]]; then
  # REGION didn't setup
  echo "AWS_REGION is missing"
  exit 1
fi

# FIXME Start scheduler on local machine. Only for developement. Will replace it by deploying it on AWS ECS
envtpl $DIR/../../../blox/deploy/docker/conf/docker-compose.yml
cd $DIR/../../../blox/deploy/conf
docker-compose up -d > /dev/null
