FROM wurstmeister/kafka

# Overwrite the default config
COPY config/server.properties ${KAFKA_HOME}/config/server.properties
COPY bin/kafka-run-class.sh ${KAFKA_HOME}/bin/kafka-run-class.sh
COPY bin/kafka-server-start.sh ${KAFKA_HOME}/bin/kafka-server-start.sh

CMD kafka-server-start.sh ${KAFKA_HOME}/config/server.properties
