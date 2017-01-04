#!/usr/bin/env bash

mysql_install_db

mysqld &
mysql_pid=$!

until mysqladmin ping > /dev/null 2>&1; do
      echo -n "."; sleep 1
done

echo "CREATE DATABASE tpcc;" | mysql -u root -h localhost

echo "Creating tables.."
cat /opt/tpcc-mysql/create_table.sql /opt/tpcc-mysql/add_fkey_idx.sql | mysql -u root -h localhost tpcc
MYSQL_PORT_3306_TCP_ADDR=mysql

echo "Loading tpcc data.."
/opt/tpcc-mysql/tpcc_load localhost tpcc root '' 20

wait $mysql_pid
