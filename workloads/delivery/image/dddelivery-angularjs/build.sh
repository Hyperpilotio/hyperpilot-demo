#!/bin/sh

docker build -t hyperpilot/dddelivery-angularjs:latest .

docker push hyperpilot/dddelivery-angularjs:latest
