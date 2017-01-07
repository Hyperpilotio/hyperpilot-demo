FROM    node:latest
RUN	apt-get update
ADD     cassandra-benchmarks-ui /cassandra-benchmarks-ui
WORKDIR /cassandra-benchmarks-ui
RUN     npm install
CMD     node bin/benchmarks-ui.js
