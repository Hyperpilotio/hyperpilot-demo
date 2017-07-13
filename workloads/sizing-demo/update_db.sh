#!/bin/bash

MONGO_URL=internal-mongo-elb-624130134.us-east-1.elb.amazonaws.com:27017
MONGO_USER=profiler
MONGO_PWD=hyperpilot

echo create node types collection in configdb
mongoimport -h $MONGO_URL -u $MONGO_USER -p $MONGO_PWD --db=configdb --collection=nodetypes --type=json --drop --file=nodetypes.json
