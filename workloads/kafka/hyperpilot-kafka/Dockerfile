FROM wurstmeister/kafka

# Overwrite the default config
COPY config/server.properties ${KAFKA_HOME}/config/server.properties
COPY config/zookeeper.properties ${KAFKA_HOME}/config/zookeeper.properties
COPY bin/kafka-run-class.sh ${KAFKA_HOME}/bin/kafka-run-class.sh
COPY bin/kafka-server-start.sh ${KAFKA_HOME}/bin/kafka-server-start.sh

ADD  mx4j-3.0.2/lib/mx4j-tools.jar ${KAFKA_HOME}/libs/mx4j-tools.jar

CMD zookeeper-server-start.sh ${KAFKA_HOME}/config/zookeeper.properties & kafka-server-start.sh ${KAFKA_HOME}/config/server.properties
