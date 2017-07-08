FROM    hyperpilot/benchmark-controller:tpcc_mysql_base

ADD     parser.js extension-lib/parser.js
ADD     config.json config/config.json
ADD     run.sh /opt/tpcc-mysql/run.sh

CMD     node /app/bin/index.js
