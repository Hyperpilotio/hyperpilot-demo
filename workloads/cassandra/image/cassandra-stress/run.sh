#!/bin/bash

/usr/bin/cassandra-stress write n=100 cl=one -mode native cql3 -schema keyspace="keyspace1" -log file=~/load_1M_rows.log -sendto cassandra-service -port native=9042 
