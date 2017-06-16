#!/bin/sh

docker build -t hyperpilot\/benchmark-controller:tpcc-mysql .

docker push hyperpilot\/benchmark-controller:tpcc-mysql
