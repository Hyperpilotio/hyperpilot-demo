#!/bin/sh

docker build -t wen777/bench:cassandra .

docker push wen777/bench:cassandra
