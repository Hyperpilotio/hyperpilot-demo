FROM wurstmeister/kafka

# Overwrite the default config
COPY zookeeper.properties ${KAFKA_HOME}/config/zookeeper.properties

CMD zookeeper-server-start.sh ${KAFKA_HOME}/config/zookeeper.properties