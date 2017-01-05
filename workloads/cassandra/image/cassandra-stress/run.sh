#!/bin/bash

/usr/bin/cassandra-stress write n=1000000 cl=one -mode native cql3 -schema keyspace="keyspace1" -log file=~/load_1M_rows.log -sendToDaemon cassandra-service -port 7199 

