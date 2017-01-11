FROM gaishimo/tpcc-mysql

RUN apt-get update && apt-get -y --force-yes install mysql-client-5.6

ADD run.sh /opt/tpcc-mysql/run.sh
ADD my.cnf /etc/mysql/my.cnf

CMD /opt/tpcc-mysql/run.sh
