FROM    hyperpilot/benchmark-controller:tpcc_mysql_base

RUN apt-get update && apt-get -y --force-yes install mysql-community-client

ADD     parser.js extension-lib/parser.js
ADD     config.json config/config.json
ADD     run.sh /opt/tpcc-mysql/run.sh

CMD     node /app/bin/index.js
