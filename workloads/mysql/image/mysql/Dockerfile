FROM gaishimo/tpcc-mysql

RUN apt-get update && apt-get -y --force-yes install mysql-client-5.6

ADD run.sh /opt/tpcc-mysql/run.sh

CMD /opt/tpcc-mysql/run.sh
