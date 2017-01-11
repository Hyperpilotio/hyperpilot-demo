FROM    hyperpilot/tpcc-mysql
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash -
RUN apt-get install -y nodejs

ADD mysql-benchmarks-ui /mysql-benchmarks-ui

WORKDIR /mysql-benchmarks-ui

CMD npm install && node bin/benchmarks-ui.js