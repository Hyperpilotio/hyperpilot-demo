FROM grafana/grafana

RUN apt-get update && apt-get install -y curl

COPY snap-influx-datasource-default.json /var/lib/grafana/initial/snap-influx-datasource-default.json
COPY demo-dashboard-default.json /var/lib/grafana/initial/demo-dashboard-default.json
COPY config-ds /var/lib/grafana/initial/config-ds
COPY run.sh /run.sh

ENV SNAP_DS_NAME snap
ENV INFLUXDB_HOST localhost
ENV INFLUXDB_PORT 8086
ENV INFLUXDB_USER root
ENV INFLUXDB_PASS root
ENV INFLUXDB_NAME snap
