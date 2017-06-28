#!/bin/sh

sudo docker build -t hyperpilot/benchmark-controller:redis . && sudo docker push hyperpilot/benchmark-controller:redis
