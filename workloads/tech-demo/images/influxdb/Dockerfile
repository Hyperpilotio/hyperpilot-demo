FROM influxdb:1.2.2

COPY influxdb.conf /etc/influxdb/influxdb.conf

EXPOSE 8083

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /*.sh
