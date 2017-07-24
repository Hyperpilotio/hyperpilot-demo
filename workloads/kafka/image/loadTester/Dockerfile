FROM java:8u111-jdk 

# Install Kafka
ARG kafka_version=0.10.2.1
ARG scala_version=2.12

RUN apt-get update -y && \
    apt-get install -y unzip wget curl docker jq coreutils

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

# A wrapper for kafka-run-class.sh
ADD bin/kafka-run-class-wrapper.sh ${KAFKA_HOME}/bin/kafka-run-class-wrapper.sh
