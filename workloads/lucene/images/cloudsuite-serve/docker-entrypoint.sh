#!/bin/bash
# clone from https://github.com/parsa-epfl/cloudsuite/tree/54089257986654368e95c3183228bd0965882a8a

#Read the server's parameters
export SERVER_HEAP_SIZE=$1 \
  && export NUM_SERVERS=$2

#RELOAD CONFIGURATION
cd $SOLR_HOME \
  && mkdir -p $SOLR_CORE_DIR \
  && cp -R server/solr/* $SOLR_CORE_DIR

chown -R $SOLR_USER:$SOLR_USER $BASE_PATH
su $SOLR_USER
#Prepare Solr
$SOLR_HOME/bin/solr start -cloud -p $SOLR_PORT -s $SOLR_CORE_DIR -m $SERVER_HEAP_SIZE
$SOLR_HOME/bin/solr status
$SOLR_HOME/bin/solr create_collection -c cloudsuite_web_search -d basic_configs -shards $NUM_SERVERS -p $SOLR_PORT
kill -9 $(pgrep java) $(pgrep java)

#Download the index
wget -O - $INDEX_URL \
  | tar zxvf - -C $SOLR_CORE_DIR/cloudsuite_web_search*

echo "================================="
echo "Index Node IP Address: "`ifconfig eth0 2>/dev/null|awk '/inet addr:/ {print $2}'|sed 's/addr://'`
echo "================================="

#Run Solr
$SOLR_HOME/bin/solr start -cloud -f -p $SOLR_PORT -s $SOLR_CORE_DIR -m $SERVER_HEAP_SIZE
