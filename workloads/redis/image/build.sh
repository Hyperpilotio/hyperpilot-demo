#!/bin/sh

docker build -t wen777/bench:redis .

docker push wen777/bench:redis
