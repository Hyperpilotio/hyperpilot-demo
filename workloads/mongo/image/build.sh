#!/bin/sh

sudo docker build -t hyperpilot/benchmark-controller:mongo . && sudo docker push hyperpilot/benchmark-controller:mongo
