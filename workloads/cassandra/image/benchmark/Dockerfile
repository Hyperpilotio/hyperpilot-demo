FROM wen777/bench:base-openjdk-8

# Add DataStax sources
RUN curl -L https://debian.datastax.com/debian/repo_key | apt-key add -
RUN echo "deb http://debian.datastax.com/community stable main" | tee -a /etc/apt/sources.list.d/cassandra.sources.list

# Workaround for https://github.com/docker/docker/issues/6345
RUN ln -s -f /bin/true /usr/bin/chfn

# Install Cassandra 3
RUN apt-get update && \
    apt-get install -y dsc30 cassandra-tools && \
    rm -rf /var/lib/apt/lists/* && \
    service cassandra stop

ADD     parser.js extension-lib/parser.js
ADD     config.json config/config.json

CMD     node bin/benchmarks-ui.js
