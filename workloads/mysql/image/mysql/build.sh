#!/bin/sh

docker build -t hyperpilot/tpcc-mysql .

docker push hyperpilot/tpcc-mysql
