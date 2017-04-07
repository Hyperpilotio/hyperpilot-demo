FROM grafana/grafana

RUN apt-get update && apt-get install -y curl

COPY snap-influx-datasource-default.json /var/lib/grafana/initial/snap-influx-datasource-default.json
COPY spark-influx-datasource-default.json /var/lib/grafana/initial/spark-influx-datasource-default.json
COPY demo-dashboard-default.json /var/lib/grafana/initial/demo-dashboard-default.json
COPY config-ds /var/lib/grafana/initial/config-ds
COPY run.sh /run.sh

ENV SNAP_DS_NAME=snap SPARK_DS_NAME=spark INFLUXDB_HOST=influxsrv.hyperpilot INFLUXDB_PORT=8086 INFLUXDB_USER=root INFLUXDB_PASS=root INFLUXDB_NAME_SNAP=snap INFLUXDB_NAME_SPARK=spark
