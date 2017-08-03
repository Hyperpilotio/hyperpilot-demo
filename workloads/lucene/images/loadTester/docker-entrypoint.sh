#!/bin/bash
# clone from https://github.com/parsa-epfl/cloudsuite/tree/54089257986654368e95c3183228bd0965882a8a
#Read Index Node's IP

# h: host, c: current users, u: ramp up, s: steady state, d: ramp down
#Read client parameters

if [ ! $1 ] || [ $1 == '?' ] || [ $1 == 'help' ]
then
    echo "Usage: entrypoint.sh [OPTIONS]"
            echo "options:"
            echo "  -h <host>"
            echo "  -c <current users>"
            echo "  -u <ramp up time in seconds"
            echo "  -s <steady state time in seconds"
            echo "  -d <ramp down time in seconds>"
            echo "example:"
            echo "entrypoint.sh -h host_server -c 10 -u 5 -s 20 -d 3"
            exit
fi

while getopts "h:c:u:s:d:l" args
do
    case $args in
        h)
            export IP=$OPTARG ;;
        c)
            export SCALE=$OPTARG ;;
        u)
            export RAMP_UP=$OPTARG ;;
        s)
            export STEADY_STATE=$OPTARG ;;
        d)
            export RAMP_DOWN=$OPTARG ;;
        esac
done

echo $IP
echo $SCALE
echo $RAMP_UP
echo $STEADY_STATE
echo $RAMP_DOWN

#Read local IP
export HOST_IP=$(echo `ifconfig eth0 2>/dev/null|awk '/inet addr:/ {print $2}'|sed 's/addr://'`) \
  && export AGENTS=$HOST_IP:$NUM_AGENTS


#PREPARE
export JAVA_HOME=$(readlink -f /usr/bin/javac | sed "s:/bin/javac::")
$FABAN_HOME/master/bin/startup.sh

#RUN
cd $FABAN_HOME/search \
	&& cp distributions/$SEARCH_DRIVER src/sample/searchdriver/SearchDriver.java


cd $FABAN_HOME/search \
	&& $ANT_HOME/bin/ant deploy

cd $FABAN_HOME/search \
	&& sed -i "/<ipAddress1>/c\<ipAddress1>$IP</ipAddress1>" deploy/run.xml \
	&& sed -i "/<portNumber1>/c\<portNumber1>$SOLR_PORT</portNumber1>" deploy/run.xml \
	&& sed -i "/<outputDir>/c\<outputDir>$FABAN_OUTPUT_DIR</outputDir>" deploy/run.xml \
	&& sed -i "/<termsFile>/c\<termsFile>$FABAN_HOME/search/src/sample/searchdriver/$TERMS_FILE</termsFile>" deploy/run.xml \
	&& sed -i "/<fa:scale>/c\<fa:scale>$SCALE</fa:scale>" deploy/run.xml \
	&& sed -i "/<agents>/c\<agents>$AGENTS</agents>" deploy/run.xml \
	&& sed -i "/<fa:rampUp>/c\<fa:rampUp>$RAMP_UP</fa:rampUp>" deploy/run.xml \
	&& sed -i "/<fa:rampDown>/c\<fa:rampDown>$RAMP_DOWN</fa:rampDown>" deploy/run.xml \
	&& sed -i "/<fa:steadyState>/c\<fa:steadyState>$STEADY_STATE</fa:steadyState>" deploy/run.xml

echo "Print= $AGENTS"

export CLASSPATH=$FABAN_HOME/lib/fabanagents.jar:$FABAN_HOME/lib/fabancommon.jar:$FABAN_HOME/lib/fabandriver.jar:$JAVA_HOME/lib/tools.jar:$FABAN_HOME/search/build/lib/search.jar

until $(curl --output /dev/null --silent --head --fail http://$IP:$SOLR_PORT); do
    printf '.'
    sleep 5
done

#START Registry
java -classpath $CLASSPATH -Djava.security.policy=$POLICY_PATH com.sun.faban.common.RegistryImpl &
sleep 3s

#START Agent
java -classpath $CLASSPATH -Xmx$CLIENT_HEAP_SIZE -Xms$CLIENT_HEAP_SIZE -Djava.security.policy=$POLICY_PATH com.sun.faban.driver.engine.AgentImpl "SearchDriver" $AGENT_ID $HOST_IP &

#START Master
java -classpath $CLASSPATH -Xmx$CLIENT_HEAP_SIZE -Xms$CLIENT_HEAP_SIZE -Djava.security.policy=$POLICY_PATH -Dbenchmark.config=$BENCHMARK_CONFIG com.sun.faban.driver.engine.MasterImpl

sleep 3s

#Output summary
cat $FABAN_OUTPUT_DIR/1/summary.xml
