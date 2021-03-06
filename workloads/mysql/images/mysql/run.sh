#!/usr/bin/env bash

mysql_install_db

cp -r /var/lib/mysql /var/lib/mysql-files
chown -R mysql /var/lib/mysql-files

mysqld &
mysql_pid=$!

until mysqladmin ping > /dev/null 2>&1; do
      echo -n "."; sleep 1
done

echo "CREATE DATABASE tpcc;" | mysql -u root -h localhost mysql
echo "GRANT ALL ON *.* to root@'tpcc-bench.weave.local'; FLUSH PRIVILEGES;" | mysql -u root -h localhost

#For development usage, comment above line and uncomment the following line
#echo "GRANT ALL ON *.* TO 'root'@'%'; FLUSH PRIVILEGES;" | mysql -u root -h localhost


echo "Creating tables.."
cat /opt/tpcc-mysql/create_table.sql /opt/tpcc-mysql/add_fkey_idx.sql | mysql -u root -h localhost tpcc
MYSQL_PORT_3306_TCP_ADDR=mysql

wait $mysql_pid
