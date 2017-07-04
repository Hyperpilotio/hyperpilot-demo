FROM wurstmeister/kafka

# Overwrite the default config
COPY config/server.properties ${KAFKA_HOME}/config/server.properties
COPY config/zookeeper.properties ${KAFKA_HOME}/config/zookeeper.properties
COPY bin/kafka-run-class.sh ${KAFKA_HOME}/bin/kafka-run-class.sh
COPY bin/kafka-server-start.sh ${KAFKA_HOME}/bin/kafka-server-start.sh

CMD zookeeper-server-start.sh ${KAFKA_HOME}/config/zookeeper.properties & kafka-server-start.sh ${KAFKA_HOME}/config/server.properties

# Remember to forward the ports 2181, 9092