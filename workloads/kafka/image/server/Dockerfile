FROM wurstmeister/kafka

# Overwrite the default config
COPY config/server.properties ${KAFKA_HOME}/config/server.properties
COPY bin/kafka-run-class.sh ${KAFKA_HOME}/bin/kafka-run-class.sh
COPY bin/kafka-server-start.sh ${KAFKA_HOME}/bin/kafka-server-start.sh

ADD  mx4j-3.0.2/lib/mx4j-tools.jar ${KAFKA_HOME}/libs/mx4j-tools.jar

CMD kafka-server-start.sh ${KAFKA_HOME}/config/server.properties
