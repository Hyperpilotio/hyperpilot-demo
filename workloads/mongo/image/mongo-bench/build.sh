#!/bin/sh

sudo docker build -t hyperpilot/mongo-bench . && sudo docker push hyperpilot/mongo-bench
