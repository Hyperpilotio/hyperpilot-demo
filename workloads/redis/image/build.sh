#!/bin/sh

docker build -t hyperpilot/bench:redis .

docker push hyperpilot/bench:redis
