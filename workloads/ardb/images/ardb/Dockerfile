FROM lupino/ardb-server

RUN sed -e 's/rocksdb.disableWAL            true/rocksdb.disableWAL            false/' -i /etc/ardb.conf

WORKDIR /var/lib/ardb

EXPOSE 16379
ENTRYPOINT /usr/bin/ardb-server /etc/ardb.conf