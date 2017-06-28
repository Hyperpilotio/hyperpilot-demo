FROM wurstmeister/kafka

COPY config/server.properties ${KAFKA_HOME}/config/server.properties
COPY config/zookeeper.properties ${KAFKA_HOME}/config/zookeeper.properties

CMD zookeeper-server-start.sh ${KAFKA_HOME}/config/zookeeper.properties & kafka-server-start.sh ${KAFKA_HOME}/config/server.properties

#(Remember to forward the ports 2181, 9092)