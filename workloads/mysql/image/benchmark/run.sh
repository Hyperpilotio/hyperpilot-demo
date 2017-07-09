#!/bin/bash

if [ -z "$SERVICE_HOST" ]; then
    echo "Setting service host default"
    SERVICE_HOST=mysql-server.default
fi

echo "Recreating tables..."
cat /opt/tpcc-mysql/create_table.sql | mysql -u root -h $SERVICE_HOST tpcc

/opt/tpcc-mysql/tpcc_load "$@"
