#!/bin/sh
while [ "$1" != "" ]; do
	case $1 in
	  "--zookeeper")
		shift
		ZK=$1
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


if [ ! $ZK ] || [ ! $PARTITIONS ] || [ ! $REPLICATION_FACTOR ] || [ ! $TOPIC ]; then
	echo "ERROR: missing parameter"
	exit 1
fi

zookeeper-shell.sh $ZK rmr /brokers/topics
kafka-topics.sh --create --zookeeper $ZK --topic $TOPIC --partitions $PARTITIONS --replication-factor $REPLICATION_FACTOR
