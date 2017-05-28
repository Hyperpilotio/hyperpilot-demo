FROM    hyperpilot/benchmark-controller:latest
RUN	    apt-get update && apt-get install -y redis-server
ADD     parser.js extension-lib/parser.js
ADD     config.json config/config.json
CMD     node bin/benchmarks-ui.js
