FROM hyperpilot/benchmark-controller

# Install Java
RUN echo deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main >> /etc/apt/sources.list.d/java-8-debian.list
RUN echo deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main >> /etc/apt/sources.list.d/java-8-debian.list

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886

RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
RUN echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
RUN apt-get update -y
RUN apt-get install -y  oracle-java8-installer
RUN apt-get install oracle-java8-set-default

# Install Kafka
ARG kafka_version=0.10.2.1
ARG scala_version=2.12

RUN apt-get update -y 
RUN apt-get install -y unzip wget curl docker jq coreutils

ENV KAFKA_VERSION=$kafka_version SCALA_VERSION=$scala_version
ADD download-kafka.sh /tmp/download-kafka.sh
RUN chmod a+x /tmp/download-kafka.sh && sync && /tmp/download-kafka.sh && tar xfz /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /opt && rm /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz && ln -s /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} /opt/kafka

VOLUME ["/kafka"]

ENV KAFKA_HOME /opt/kafka
ENV PATH ${PATH}:${KAFKA_HOME}/bin

# Add kafka-topic wrapper
ADD bin/kafka-delete-and-create-topic.sh ${KAFKA_HOME}/bin/kafka-delete-and-create-topic.sh

# Overwrite Kafka config
COPY config/consumer.properties ${KAFKA_HOME}/config/consumer.properties
COPY config/producer.properties ${KAFKA_HOME}/config/producer.properties

# Overwrite benchmark-controller 
ADD     parser.js extension-lib/parser.js
ADD     config.json config/config.json
