#!/bin/sh

docker build -t wen777/bench:tpcc-mysql .

docker push wen777/bench:tpcc-mysql
