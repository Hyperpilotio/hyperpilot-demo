#!/bin/sh

docker build -t hyperpilot\/load-tester:tpcc-mysql .

docker push hyperpilot\/load-tester:tpcc-mysql
