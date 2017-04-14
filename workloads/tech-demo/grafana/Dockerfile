FROM grafana/grafana

RUN apt-get update && apt-get install -y curl

COPY *.json /var/lib/grafana/initial/
COPY config-ds /var/lib/grafana/initial/config-ds
COPY run.sh /run.sh

ENV SNAP_DS_NAME=snap SPARK_DS_NAME=spark INFLUXDB_HOST=influxsrv.hyperpilot INFLUXDB_PORT=8086 INFLUXDB_USER=root INFLUXDB_PASS=root INFLUXDB_NAME_SNAP=snap INFLUXDB_NAME_SPARK=spark
