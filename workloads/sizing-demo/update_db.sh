#!/bin/bash

if [ -z "$1" ]
then
    MONGO_URL=localhost:27017
else
    MONGO_URL=$1
fi

MONGO_USER=analyzer
MONGO_PWD=hyperpilot

echo create node types collection in configdb
mongoimport -h $MONGO_URL -u $MONGO_USER -p $MONGO_PWD --db=configdb --collection=nodetypes --type=json --drop --file=nodetypes.json
echo create previous generation collection in configdb
mongoimport -h $MONGO_URL -u $MONGO_USER -p $MONGO_PWD --db=configdb --collection=previousgenerations --type=json --drop --file=previous_generation.json
