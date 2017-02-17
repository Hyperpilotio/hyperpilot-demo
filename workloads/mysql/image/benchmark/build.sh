#!/bin/sh

docker build -t hyperpilot/bench:tpcc-mysql .

docker push hyperpilot/bench:tpcc-mysql
