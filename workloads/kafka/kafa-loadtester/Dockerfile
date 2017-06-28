FROM 	wurstmeister/kafka

ADD 	bin/kafka-delete-and-create-topic.sh ${KAFKA_HOME}/bin/kafka-delete-and-create-topic.sh

COPY 	config/consumer.properties ${KAFKA_HOME}/config/consumer.properties
COPY 	config/producer.properties ${KAFKA_HOME}/config/producer.properties