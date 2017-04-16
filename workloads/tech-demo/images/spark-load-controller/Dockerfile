FROM hyperpilot/spark:2.1.0-hadoop-2.7-influx

WORKDIR $SPARK_HOME
ADD *.sh ./

CMD ["./run_jobs.sh", "2"]
