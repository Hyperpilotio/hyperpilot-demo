FROM influxdb:1.3.6

COPY influxdb.conf /etc/influxdb/influxdb.conf

# set default db retention to 3 hours
ENV DB_RETENTION_HOURS=3h

EXPOSE 8083

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /*.sh
