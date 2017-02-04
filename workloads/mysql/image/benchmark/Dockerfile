FROM    hyperpilot/bench:base-mysql-tpcc

ADD     parser.js extension-lib/parser.js
ADD     config.json config/config.json

CMD     node bin/benchmarks-ui.js

