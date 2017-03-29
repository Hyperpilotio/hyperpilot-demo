#!/bin/bash

export DOCKER_REGISTRY_SERVER=https://index.docker.io/v1/
export DOCKER_USER=hyperpilot
export DOCKER_EMAIL=tim@hyperpilot.io
export DOCKER_PASSWORD=hyper123

kubectl create secret  --namespace='hyperpilot' docker-registry myregistrykey \
--docker-server=$DOCKER_REGISTRY_SERVER \
--docker-username=$DOCKER_USER \
--docker-password=$DOCKER_PASSWORD \
--docker-email=$DOCKER_EMAIL
