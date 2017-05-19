#!/bin/sh

docker build -t hyperpilot/benchmark-controller:redis .

docker push hyperpilot/benchmark-controller:redis
