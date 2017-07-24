#!/bin/sh

while [ "$1" != "" ]; do
	case $1 in
	  "--zookeeper-host")
			shift
    	ZK_HOST=$1
			;;
	  "--zookeeper-port")
	    shift
	    ZK_PORT=$1
	    ;;
	  "--partitions")
	    shift
	    PARTITIONS=$1
	    ;;
	  "--replication-factor")
	    shift
	    REPLICATION_FACTOR=$1
	    ;;
	  "--topic")
	    shift
	    TOPIC=$1
	    ;;
	  *)
        echo "ERROR: unknown parameter \"$1\""
        exit 1
        ;;
	esac
	shift
done

if [	"X$ZK_PORT" != "X"	]; then
			ZK="$ZK_HOST:$ZK_PORT"
else 
			ZK="$ZK_HOST"
fi

if [ ! $ZK ] || [ ! $PARTITIONS ] || [ ! $REPLICATION_FACTOR ] || [ ! $TOPIC ]; then
	echo "ERROR: missing parameter"
	echo "ZK = $ZK"
	echo "PARTITIONS = $PARTITIONS"
	echo "REPLICATION_FACTOR = $REPLICATION_FACTOR"
	echo "TOPIC = $TOPIC"
	exit 1
fi

echo "deleting topic: $TOPIC";
kafka-topics.sh --delete --zookeeper $ZK --topic $TOPIC --if-exist

while [ $(kafka-topics.sh --list --zookeeper $ZK | grep $TOPIC | wc -l) -ne "0" ]
do
	echo "remaining topics: ";
	kafka-topics.sh --list --zookeeper $ZK;
	sleep 2;
done

kafka-topics.sh --create --zookeeper $ZK --topic $TOPIC --partitions $PARTITIONS --replication-factor $REPLICATION_FACTOR --if-not-exists
kafka-configs.sh --alter --zookeeper $ZK --entity-type=topics --entity-name $TOPIC --add-config retention.bytes=1
