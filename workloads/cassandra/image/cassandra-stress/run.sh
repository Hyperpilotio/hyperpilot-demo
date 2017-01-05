#!/bin/bash

echo "deb http://debian.datastax.com/community stable main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list

curl -L https://debian.datastax.com/debian/repo_key | sudo apt-key add -

sudo apt-get update && \
    sudo apt-get install dsc21=2.1.5-1 && \
    sudo apt-get install cassandra-tools=2.1.5

/usr/bin/cassandra-stress write n=1000000 cl=one -mode native cql3 -schema keyspace="keyspace1" -log file=~/load_1M_rows.log -sendToDaemon cassandra-service -port 7199 

