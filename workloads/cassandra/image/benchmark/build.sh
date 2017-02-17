#!/bin/sh

docker build -t hyperpilot/bench:cassandra .

docker push hyperpilot/bench:cassandra
