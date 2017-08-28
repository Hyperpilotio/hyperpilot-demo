FROM gaishimo/tpcc-mysql

RUN apt-get update && apt-get -y --force-yes install mysql-community-client

ADD run.sh /opt/tpcc-mysql/run.sh
ADD my.cnf /etc/mysql/my.cnf
ADD drop_table.sh /opt/tpcc-mysql/drop_table.sh

CMD /opt/tpcc-mysql/run.sh
