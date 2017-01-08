#!/usr/bin/env bash

# Get running container's IP
IP=`hostname --ip-address`
if [ $# == 1 ]; then SEEDS="$1,$IP"; 
else SEEDS="$IP"; fi

# Accept listen_address
IP=${LISTEN_ADDRESS:-`hostname --ip-address`}



sed -i -e "s/# broadcast_address.*/broadcast_address: $IP/"              $CASSANDRA_CONFIG/cassandra.yaml
sed -i -e "s/# broadcast_rpc_address.*/broadcast_rpc_address: $IP/"              $CASSANDRA_CONFIG/cassandra.yaml
sed -i -e "s/^commitlog_segment_size_in_mb.*/commitlog_segment_size_in_mb: 64/"              $CASSANDRA_CONFIG/cassandra.yaml

# 0.0.0.0 Listens on all configured interfaces
# but you must set the broadcast_rpc_address to a value other than 0.0.0.0
sed -i -e "s/^rpc_address.*/rpc_address: 0.0.0.0/" $CASSANDRA_CONFIG/cassandra.yaml

# Be your own seed
sed -i -e "s/- seeds: \"127.0.0.1\"/- seeds: \"$SEEDS\"/" $CASSANDRA_CONFIG/cassandra.yaml

# Listen on IP:port of the container
sed -i -e "s/^listen_address.*/listen_address: $IP/" $CASSANDRA_CONFIG/cassandra.yaml

# With virtual nodes disabled, we need to manually specify the token
echo "JVM_OPTS=\"\$JVM_OPTS -Dcassandra.initial_token=0\"" >> $CASSANDRA_CONFIG/cassandra-env.sh

# Pointless in one-node cluster, saves about 5 sec waiting time
echo "JVM_OPTS=\"\$JVM_OPTS -Dcassandra.skip_wait_for_gossip_to_settle=0\"" >> $CASSANDRA_CONFIG/cassandra-env.sh

# Most likely not needed
echo "JVM_OPTS=\"\$JVM_OPTS -Djava.rmi.server.hostname=$IP\"" >> $CASSANDRA_CONFIG/cassandra-env.sh

# If configured in $CASSANDRA_DC, set the cassandra datacenter.
if [ ! -z "$CASSANDRA_DC" ]; then
    sed -i -e "s/endpoint_snitch: SimpleSnitch/endpoint_snitch: PropertyFileSnitch/" $CASSANDRA_CONFIG/cassandra.yaml
    echo "default=$CASSANDRA_DC:rac1" > $CASSANDRA_CONFIG/cassandra-topology.properties
fi

echo Starting Cassandra on $IP...

exec cassandra -f

# # Accept seeds via docker run -e SEEDS=seed1,seed2,...
# SEEDS=${SEEDS:-$IP}

# # Backwards compatibility with older scripts that just passed the seed in
# if [ $# == 1 ]; then SEEDS="$1,$SEEDS"; fi

# #if this container was linked to any other cassandra nodes, use them as seeds as well.
# if [[ `env | grep _PORT_9042_TCP_ADDR` ]]; then
#   SEEDS="$SEEDS,$(env | grep _PORT_9042_TCP_ADDR | sed 's/.*_PORT_9042_TCP_ADDR=//g' | sed -e :a -e N -e 's/\n/,/' -e ta)"
# fi

# echo Configuring Cassandra to listen at $IP with seeds $SEEDS

# # Setup Cassandra
# DEFAULT=${DEFAULT:-/etc/cassandra/default.conf}
# CONFIG=/etc/cassandra/conf

# sed -i -e "s/# JVM_OPTS=\"\$JVM_OPTS -Djava.rmi.server.hostname=<public name>\"/JVM_OPTS=\"\$JVM_OPTS -Djava.rmi.server.hostname=$IP\"/" $CASSANDRA_CONFIG/cassandra-env.sh
# sed -i -e "s/LOCAL_JMX=yes/LOCAL_JMX=no/" $CASSANDRA_CONFIG/cassandra-env.sh
# sed -i -e "s/JVM_OPTS=\"\$JVM_OPTS -Dcom.sun.management.jmxremote.authenticate=true\"/JVM_OPTS=\"\$JVM_OPTS -Dcom.sun.management.jmxremote.authenticate=false\"/" $CASSANDRA_CONFIG/cassandra-env.sh

# if [[ $SNITCH ]]; then
#   sed -i -e "s/endpoint_snitch: SimpleSnitch/endpoint_snitch: $SNITCH/" $CASSANDRA_CONFIG/cassandra.yaml
# fi
# if [[ $DC && $RACK ]]; then
#   echo "dc=$DC" > $CASSANDRA_CONFIG/cassandra-rackdc.properties
#   echo "rack=$RACK" >> $CASSANDRA_CONFIG/cassandra-rackdc.properties
# fi

