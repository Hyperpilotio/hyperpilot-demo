#!/bin/bash

/usr/bin/cassandra-stress write n=100 cl=one -mode native cql3 -schema keyspace="keyspace1" -node cassandra-service
