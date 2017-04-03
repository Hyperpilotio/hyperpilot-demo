FROM hyperpilot/spark:2.1.0-hadoop-2.7-influx

WORKDIR $SPARK_HOME
ADD run.sh ./run.sh

CMD ["bin/spark-class", "org.apache.spark.deploy.master.Master"]
