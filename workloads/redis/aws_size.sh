#!/bin/bash

PROFILER_URL=a4c51bb336f7811e7ad9a02954c97250-1848550319.us-east-1.elb.amazonaws.com
curl -XPOST -H "Content-Type: application/json" http://$PROFILER_URL:7779/sizing/aws/redis
