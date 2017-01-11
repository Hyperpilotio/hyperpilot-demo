FROM    node:latest
RUN	apt-get update && apt-get install -y redis-server
ADD     redis-benchmarks-ui /redis-benchmarks-ui
WORKDIR /redis-benchmarks-ui
RUN     npm install && \
        npm i os --save && \
        npm install node-uuid --save && \
        npm install influx@next --save && \ 
        npm install request --save && \
        npm install querystring --save
CMD     node bin/benchmarks-ui.js
