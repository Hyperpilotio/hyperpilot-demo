#!/bin/bash
set -e

set -m
INFLUX_HOST="localhost"

# Check if influxdb defined ENV INFLUXDB_HTTP_BIND_ADDRESS is given
if [[ -z "$INFLUXDB_HTTP_BIND_ADDRESS" ]]
then
    # bind address is not set, use default 8086
    INFLUX_API_PORT="8086"
else
    # bind address is set, remove prefix ":" char 
    INFLUX_API_PORT=${INFLUXDB_HTTP_BIND_ADDRESS#":"}
fi

# check if influxdb defined ENV INFLUXDB_DATA_DIR is given
DATA_DIR="${INFLUXDB_DATA_DIR:-/var/lib/influxdb/data}"


API_URL="http://${INFLUX_HOST}:${INFLUX_API_PORT}"
if [ "${1:0:1}" = '-' ]; then
    set -- influxd "$@"
fi

echo "=> Starting InfluxDB ..."
exec "$@" &


# Pre create database on the initiation of the container
if [ -n "${PRE_CREATE_DB}" ]; then
    echo "=> About to create the following database: ${PRE_CREATE_DB}"
    if [ -f "${DATA_DIR}/.pre_db_created" ]; then
        echo "=> Database had been created before, skipping ..."
    else
        arr=$(echo ${PRE_CREATE_DB} | tr ";" "\n")

        #wait for the startup of influxdb
        RET=1
        while [[ RET -ne 0 ]]; do
            echo "=> Waiting for confirmation of InfluxDB service startup ..."
            sleep 3
            curl -k ${API_URL}/ping 2> /dev/null
            RET=$?
        done
        echo ""

        PASS=${INFLUXDB_INIT_PWD:-root}
        if [ -n "${ADMIN_USER}" ]; then
          echo "=> Creating admin user"
          influx -host=${INFLUX_HOST} -port=${INFLUX_API_PORT} -execute="CREATE USER ${ADMIN_USER} WITH PASSWORD '${PASS}' WITH ALL PRIVILEGES"
          for x in $arr
          do
              echo "=> Creating database: ${x}"
              influx -host=${INFLUX_HOST} -port=${INFLUX_API_PORT} -username=${ADMIN_USER} -password="${PASS}" -execute="create database ${x}"
              influx -host=${INFLUX_HOST} -port=${INFLUX_API_PORT} -username=${ADMIN_USER} -password="${PASS}" -execute="grant all PRIVILEGES on ${x} to ${ADMIN_USER}"
              influx -host=${INFLUX_HOST} -port=${INFLUX_API_PORT} -username=${ADMIN_USER} -password="${PASS}" -execute="alter retention policy autogen ON ${x} DURATION ${DB_RETENTION_HOURS} REPLICATION 1 shard duration ${DB_RETENTION_HOURS} DEFAULT"
          done
          echo ""
          if [[ "${TELEGRAF_HOST_SNAP}" ]]; then
              influx -host=${INFLUX_HOST} -port=${INFLUX_API_PORT} -username=${ADMIN_USER} -password="${PASS}" -execute="CREATE SUBSCRIPTION sub_snap ON snap.autogen DESTINATIONS ALL '${TELEGRAF_HOST_SNAP}'"
          fi
          if [[ "${TELEGRAF_HOST_SPARK}" ]]; then
              influx -host=${INFLUX_HOST} -port=${INFLUX_API_PORT} -username=${ADMIN_USER} -password="${PASS}" -execute="CREATE SUBSCRIPTION sub_spark ON spark.autogen DESTINATIONS ALL '${TELEGRAF_HOST_SPARK}'"
          fi
        else
          for x in $arr
          do
              echo "=> Creating database: ${x}"
              influx -host=${INFLUX_HOST} -port=${INFLUX_API_PORT} -execute="create database \"${x}\""
              influx -host=${INFLUX_HOST} -port=${INFLUX_API_PORT} -execute="alter retention policy autogen ON ${x} DURATION ${DB_RETENTION_HOURS} REPLICATION 1  shard duration ${DB_RETENTION_HOURS} DEFAULT"
          done
          if [[ "${TELEGRAF_HOST_SNAP}" ]]; then
              influx -host=${INFLUX_HOST} -port=${INFLUX_API_PORT} -execute="CREATE SUBSCRIPTION sub_snap ON snap.autogen DESTINATIONS ALL '${TELEGRAF_HOST_SNAP}'"
          fi
          if [[ "${TELEGRAF_HOST_SPARK}" ]]; then
              influx -host=${INFLUX_HOST} -port=${INFLUX_API_PORT} -execute="CREATE SUBSCRIPTION sub_spark ON spark.autogen DESTINATIONS ALL '${TELEGRAF_HOST_SPARK}'"
          fi
        fi

        touch "${DATA_DIR}/.pre_db_created"
        echo "=> Done createing the following database: ${PRE_CREATE_DB}"
    fi
else
    echo "=> No database need to be pre-created"
fi

fg
