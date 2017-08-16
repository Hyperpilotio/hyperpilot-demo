#!/bin/bash

echo "Recreating tables..."
cat /opt/tpcc-mysql/create_table.sql | mysql -u root -h $1 tpcc

/opt/tpcc-mysql/tpcc_load "$@"
