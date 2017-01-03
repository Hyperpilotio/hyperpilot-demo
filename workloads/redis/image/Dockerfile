FROM    node:latest
RUN	apt-get update && apt-get install -y redis-server
ADD     redis-benchmarks-ui /redis-benchmarks-ui
WORKDIR /redis-benchmarks-ui
RUN     npm install
CMD     node bin/benchmarks-ui.js
