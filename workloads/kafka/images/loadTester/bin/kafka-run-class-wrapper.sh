#!/bin/sh

KAFKA_HOST=$2
shift 2

KAFKA_PORT=$2
shift 2

ZOOKEEPER_HOST=$2
shift 2

ZOOKEEPER_PORT=$2
shift 2

ARGS=$@

if [ "X$KAFKA_PORT" != "X" ]; then
			KAFKA_ADDRESS="$KAFKA_HOST:$KAFKA_PORT"
else
			KAFKA_ADDRESS="$KAFKA_HOST"
fi


if [ "X$ZOOKEEPER_PORT" != "X" ]; then
			ZOOKEEPER_ADDRESS="$ZOOKEEPER_HOST:$ZOOKEEPER_PORT"
else
			ZOOKEEPER_ADDRESS="$ZOOKEEPER_HOST"
fi

if [ ! $ZOOKEEPER_ADDRESS	] || [ ! $KAFKA_ADDRESS ]; then
	echo "ERROR: missing parameter ..."
	echo "ZOOKEEPER_ADDRESS = $ZOOKEEPER_ADDRESS"
	echo "KAFKA_ADDRESS = $KAFKA_ADDRESS"
	exit 1
fi
echo "Generating config files ..."

# Generate config folder and files according to the arguments
echo "generate_consumer_properties.sh $ZOOKEEPER_ADDRESS > ${KAFKA_HOME}/config/consumer.properties"
generate_consumer_properties.sh $ZOOKEEPER_ADDRESS > ${KAFKA_HOME}/config/consumer.properties

echo "generate_producer_properties.sh $KAFKA_ADDRESS > ${KAFKA_HOME}/config/producer.properties"
generate_producer_properties.sh $KAFKA_ADDRESS > ${KAFKA_HOME}/config/producer.properties

# Call kafka-run-class.sh
echo "kafka-run-class.sh $ARGS"
kafka-run-class.sh $ARGS
